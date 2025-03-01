<?php

namespace App\Utils;

use App\Models\User;
use App\Models\Node;
use App\Models\Relay;
use App\Services\Config;
use App\Controllers\LinkController;
use App\Controllers\ConfController;

class URL
{
    /*
    * 1 SSR can
    * 2 SS can
    * 3 Both can
    */
    public static function CanMethodConnect($method)
    {
        $ss_aead_method_list = Config::getSupportParam('ss_aead_method');
        if (in_array($method, $ss_aead_method_list)) {
            return 2;
        }
        return 3;
    }

    /*
    * 1 SSR can
    * 2 SS can
    * 3 Both can
    */
    public static function CanProtocolConnect($protocol)
    {
        if ($protocol != 'origin') {
            if (strpos($protocol, '_compatible') === false) {
                return 1;
            }

            return 3;
        }
        return 3;
    }

    /*
    * 1 SSR can
    * 2 SS can
    * 3 Both can
    * 4 Both can, But ssr need set obfs to plain
    * 5 Both can, But ss need set obfs to plain
    */
    public static function CanObfsConnect($obfs)
    {
        if ($obfs != 'plain') {
            //SS obfs only
            $ss_obfs = Config::getSupportParam('ss_obfs');
            if (in_array($obfs, $ss_obfs)) {
                if (strpos($obfs, '_compatible') === false) {
                    return 2;
                }

                return 4; //SSR need origin plain
            }

            if (strpos($obfs, '_compatible') === false) {
                return 1;
            }

            return 5; //SS need plain
        }

        return 3;
    }

    public static function parse_args($origin)
    {
        // parse xxx=xxx|xxx=xxx to array(xxx => xxx, xxx => xxx)
        $args_explode = explode('|', $origin);

        $return_array = [];
        foreach ($args_explode as $arg) {
            $split_point = strpos($arg, '=');

            $return_array[substr($arg, 0, $split_point)] = substr($arg, $split_point + 1);
        }

        return $return_array;
    }

    public static function SSCanConnect($user, $mu_port = 0)
    {
        if ($mu_port != 0) {
            $mu_user = User::where('port', '=', $mu_port)->where('is_multi_user', '<>', 0)->first();
            if ($mu_user == null) {
                return;
            }
            return self::SSCanConnect($mu_user);
        }
        return self::CanMethodConnect($user->method) >= 2 && self::CanProtocolConnect($user->protocol) >= 2 && self::CanObfsConnect($user->obfs) >= 2;
    }

    public static function SSRCanConnect($user, $mu_port = 0)
    {
        if ($mu_port != 0) {
            $mu_user = User::where('port', '=', $mu_port)->where('is_multi_user', '<>', 0)->first();
            if ($mu_user == null) {
                return;
            }
            return self::SSRCanConnect($mu_user);
        }
        return self::CanMethodConnect($user->method) != 2 && self::CanProtocolConnect($user->protocol) != 2 && self::CanObfsConnect($user->obfs) != 2;
    }

    public static function getSSConnectInfo($user)
    {
        $new_user = clone $user;
        if (self::CanObfsConnect($new_user->obfs) == 5) {
            $new_user->obfs = 'plain';
            $new_user->obfs_param = '';
        }
        if (self::CanProtocolConnect($new_user->protocol) == 3) {
            $new_user->protocol = 'origin';
            $new_user->protocol_param = '';
        }
        $new_user->obfs = str_replace('_compatible', '', $new_user->obfs);
        $new_user->protocol = str_replace('_compatible', '', $new_user->protocol);
        return $new_user;
    }

    public static function getSSRConnectInfo($user)
    {
        $new_user = clone $user;
        if (self::CanObfsConnect($new_user->obfs) == 4) {
            $new_user->obfs = 'plain';
            $new_user->obfs_param = '';
        }
        $new_user->obfs = str_replace('_compatible', '', $new_user->obfs);
        $new_user->protocol = str_replace('_compatible', '', $new_user->protocol);
        return $new_user;
    }

    public static function getAllItems(
        $user,
        $is_mu = 0,
        $is_ss = 0
    ) {
        $return_array = array();
        if ($user->is_admin) {
            $nodes = Node::where(
                static function ($query) {
                    $query->where('sort', 0)->orwhere('sort', 10);
                }
            )
                ->where('type', '1')
                ->orderBy('name')
                ->get();
        } else {
            $nodes = Node::where(
                static function ($query) {
                    $query->where('sort', 0)->orwhere('sort', 10);
                }
            )
                ->where(
                    static function ($query) use ($user) {
                        $query->where('node_group', '=', $user->node_group)
                            ->orWhere('node_group', '=', 0);
                    }
                )
                ->where('type', '1')
                ->where('node_class', '<=', $user->class)
                ->orderBy('name')
                ->get();
        }
        if ($is_mu) {
            if ($user->is_admin) {
                if ($is_mu != 1) {
                    $mu_nodes = Node::where('sort', 9)->where('server', '=', $is_mu)->where('type', '1')->get();
                } else {
                    $mu_nodes = Node::where('sort', 9)->where('type', '1')->get();
                }
            } elseif ($is_mu != 1) {
                $mu_nodes = Node::where('sort', 9)->where('server', '=', $is_mu)->where('node_class', '<=', $user->class)->where('type', '1')->where(
                    static function ($query) use ($user) {
                        $query->where('node_group', '=', $user->node_group)
                            ->orWhere('node_group', '=', 0);
                    }
                )->get();
            } else {
                $mu_nodes = Node::where('sort', 9)->where('node_class', '<=', $user->class)->where('type', '1')->where(
                    static function ($query) use ($user) {
                        $query->where('node_group', '=', $user->node_group)
                            ->orWhere('node_group', '=', 0);
                    }
                )->get();
            }
        }
        $relay_rules = Relay::where('user_id', $user->id)->orwhere('user_id', 0)->orderBy('id', 'asc')->get();
        if (!Tools::is_protocol_relay($user)) {
            $relay_rules = array();
        }
        foreach ($nodes as $node) {
            if ($node->mu_only != 1 && $is_mu == 0) {
                if ($node->sort == 10) {
                    $relay_rule_id = 0;
                    $relay_rule = Tools::pick_out_relay_rule($node->id, $user->port, $relay_rules);
                    if (($relay_rule != null) && $relay_rule->dist_node() != null) {
                        $relay_rule_id = $relay_rule->id;
                    }
                    $item = self::getItem($user, $node, 0, $relay_rule_id, $is_ss);
                    if ($item != null) {
                        $return_array[] = $item;
                    }
                } else {
                    $item = self::getItem($user, $node, 0, 0, $is_ss);
                    if ($item != null) {
                        $return_array[] = $item;
                    }
                }
            }
            if ($node->custom_rss == 1 && $node->mu_only != -1 && $is_mu != 0) {
                foreach ($mu_nodes as $mu_node) {
                    if ($node->sort == 10) { // ss 中转
                        $relay_rule_id = 0;
                        $relay_rule = Tools::pick_out_relay_rule($node->id, $mu_node->server, $relay_rules);
                        if (($relay_rule != null) && $relay_rule->dist_node() != null) {
                            $relay_rule_id = $relay_rule->id;
                        }
                        $item = self::getItem($user, $node, $mu_node->server, $relay_rule_id, $is_ss);
                        if ($item != null) {
                            $return_array[] = $item;
                        }
                    } else {
                        $item = self::getItem($user, $node, $mu_node->server, 0, $is_ss);
                        if ($item != null) {
                            $return_array[] = $item;
                        }
                    }
                }
            }
        }

        return $return_array;
    }

    public static function getAllUrl($user, $is_mu, $is_ss = 0, $getV2rayPlugin = 1)
    {
        $return_url = '';
        if (strtotime($user->expire_in) < time()) {
            return $return_url;
        }
        $items = self::getAllItems($user, $is_mu, $is_ss);
        foreach ($items as $item) {
            $return_url .= self::getItemUrl($item, $is_ss) . PHP_EOL;
        }
        $is_mu = $is_mu == 0 ? 1 : 0;
        $items = self::getAllItems($user, $is_mu, $is_ss);
        foreach ($items as $item) {
            $return_url .= self::getItemUrl($item, $is_ss) . PHP_EOL;
        }

        return $return_url;
    }

    /**
     * 获取全部节点 Url
     *
     * @param object $user           用户
     * @param int    $is_ss          是否 ss
     * @param int    $getV2rayPlugin 是否获取 V2rayPlugin 节点
     * @param array  $Rule           节点筛选规则
     * @param bool   $find           是否筛选节点
     *
     * @return string
     */
    public static function get_NewAllUrl($user, $is_ss, $getV2rayPlugin, $Rule, $find)
    {
        $return_url = '';
        if (strtotime($user->expire_in) < time()) {
            return $return_url;
        }
        if ($getV2rayPlugin === 0) {
            $items = array_merge(
                self::getAllItems($user, 0, $is_ss),
                self::getAllItems($user, 1, $is_ss)
            );
        } else {
            $items = array_merge(
                self::getAllItems($user, 0, $is_ss),
                self::getAllItems($user, 1, $is_ss),
                self::getAllV2RayPluginItems($user)
            );
        }
        if ($find) {
            foreach ($items as $item) {
                $item = ConfController::getMatchProxy($item, $Rule);
                if ($item !== null) {
                    $return_url .= self::getItemUrl($item, $is_ss) . PHP_EOL;
                }
            }
        } else {
            foreach ($items as $item) {
                $return_url .= self::getItemUrl($item, $is_ss) . PHP_EOL;
            }
        }

        return $return_url;
    }

    public static function getItemUrl($item, $is_ss)
    {
        $ss_obfs_list = Config::getSupportParam('ss_obfs');
        if (!$is_ss) {
            $ssurl = $item['address'] . ':' . $item['port'] . ':' . $item['protocol'] .
                ':' . $item['method'] . ':' . $item['obfs'] . ':' .
                Tools::base64_url_encode(
                    $item['passwd']
                ) . '/?obfsparam=' . Tools::base64_url_encode(
                    $item['obfs_param']
                ) . '&protoparam=' . Tools::base64_url_encode(
                    $item['protocol_param']
                ) . '&remarks=' . Tools::base64_url_encode(
                    $item['remark']
                ) . '&group=' . Tools::base64_url_encode(
                    $item['group']
                );
            return 'ssr://' . Tools::base64_url_encode($ssurl);
        }

        if ($is_ss == 2) {
            $personal_info = $item['method'] . ':' . $item['passwd'] . '@' . $item['address'] . ':' . $item['port'];
            $ssurl = 'ss://' . Tools::base64_url_encode($personal_info);
            $ssurl .= '#' . rawurlencode(Config::get('appName') . ' - ' . $item['remark']);
        } else {
            $personal_info = $item['method'] . ':' . $item['passwd'];
            $ssurl = 'ss://' . Tools::base64_url_encode($personal_info) . '@' . $item['address'] . ':' . $item['port'];
            $plugin = '';
            if ($item['obfs'] == 'v2ray' || in_array($item['obfs'], $ss_obfs_list)) {
                if (strpos($item['obfs'], 'http') !== false) {
                    $plugin .= 'obfs-local;obfs=http';
                } elseif (strpos($item['obfs'], 'tls') !== false) {
                    $plugin .= 'obfs-local;obfs=tls';
                } else {
                    $plugin .= 'v2ray;' . $item['obfs_param'];
                }
                if ($item['obfs_param'] != '' && $item['obfs'] != 'v2ray') {
                    $plugin .= ';obfs-host=' . $item['obfs_param'];
                }
                $ssurl .= '?plugin=' . rawurlencode($plugin);
            }
            $ssurl .= '#' . rawurlencode(
                Config::get('appName') . ' - ' . $item['remark']
            );
        }
        return $ssurl;
    }

    /**
     * 获取 V2RayPlugin 全部节点
     *
     * @param object $user 用户
     *
     * @return array
     */
    public static function getAllV2RayPluginItems($user) {
        $return_array = array();
        if ($user->is_admin) {
            $nodes = Node::where('sort', 13)
                ->where('type', '1')
                ->orderBy('name')
                ->get();
        } else {
            $nodes = Node::where('sort', 13)
                ->where(
                    static function ($query) use ($user) {
                        $query->where('node_group', '=', $user->node_group)
                            ->orWhere('node_group', '=', 0);
                    }
                )
                ->where('type', '1')
                ->where('node_class', '<=', $user->class)
                ->orderBy('name')
                ->get();
        }
        foreach ($nodes as $node) {
            $item = self::getV2RayPluginItem($user, $node);
            if ($item != null) {
                $return_array[] = $item;
            }
        }

        return $return_array;
    }

    /**
     * 获取 V2RayPlugin 节点
     *
     * @param object $user 用户
     * @param object $node 节点
     *
     * @return array
     */
    public static function getV2RayPluginItem($user, $node)
    {
        // 非 AEAD 加密无法使用
        if (!in_array($user->method, Config::getSupportParam('ss_aead_method'))) {
            return null;
        }
        $return_array = Tools::ssv2Array($node->server);
        $return_array['remark'] = $node->name;
        $return_array['address'] = $return_array['add'];
        $return_array['method'] = $user->method;
        $return_array['passwd'] = $user->passwd;
        $return_array['protocol'] = 'origin';
        $return_array['protocol_param'] = '';
        $return_array['obfs'] = 'v2ray';
        if ($return_array['tls'] == 'tls' && $return_array['net'] == 'ws') {
            $return_array['obfs_param'] = ('mode=ws;security=tls;path=' . $return_array['path'] .
                ';host=' . $return_array['host']);
        } else {
            $return_array['obfs_param'] = ('mode=ws;security=none;path=' . $return_array['path'] .
                ';host=' . $return_array['host']);
        }
        $return_array['path'] = ($return_array['path'] . '?redirect=' . $user->getMuMd5());
        $return_array['class'] = $node->node_class;
        $return_array['group'] = Config::get('appName');

        return $return_array;
    }

    public static function getV2Url($user, $node, $arrout = 0)
    {
        $item = Tools::v2Array($node->server);
        $item['v'] = '2';
        $item['ps'] = $node->name;
        $item['id'] = $user->getUuid();
        $item['class'] = $node->node_class;
        if ($arrout == 0) {
            return 'vmess://' . base64_encode(
                json_encode($item, 320)
            );
        }

        return $item;
    }

    public static function getAllVMessUrl($user, $arrout = 0)
    {
        if ($user->is_admin) {
            $nodes = Node::where(
                static function ($query) {
                    $query->where('sort', 11)
                        ->orwhere('sort', 12);
                }
            )
                ->where('type', '1')
                ->orderBy('name')
                ->get();
        } else {
            $nodes = Node::where(
                static function ($query) {
                    $query->where('sort', 11)
                        ->orwhere('sort', 12);
                }
            )->where(
                static function ($query) use ($user) {
                    $query->where('node_group', '=', $user->node_group)
                        ->orWhere('node_group', '=', 0);
                }
            )
                ->where('type', '1')
                ->where('node_class', '<=', $user->class)
                ->orderBy('name')
                ->get();
        }
        if ($arrout == 0) {
            $result = '';
            foreach ($nodes as $node) {
                $result .= (self::getV2Url($user, $node, $arrout) . "\n");
            }
        } else {
            $result = [];
            foreach ($nodes as $node) {
                $result[] = self::getV2Url($user, $node, $arrout);
            }
        }
        return $result;
    }

    public static function getAllSSDUrl($user)
    {
        if (!self::SSCanConnect($user)) {
            return null;
        }
        $array_all = array();
        $array_all['airport'] = Config::get('appName');
        $array_all['port'] = $user->port;
        $array_all['encryption'] = $user->method;
        $array_all['password'] = $user->passwd;
        $array_all['traffic_used'] = Tools::flowToGB($user->u + $user->d);
        $array_all['traffic_total'] = Tools::flowToGB($user->transfer_enable);
        $array_all['expiry'] = $user->class_expire;
        $array_all['url'] = Config::get('subUrl') . LinkController::GenerateSSRSubCode($user->id, 0) . '?ssd=1';
        $plugin_options = '';
        if (strpos($user->obfs, 'http') != false) {
            $plugin_options = 'obfs=http';
        }
        if (strpos($user->obfs, 'tls') != false) {
            $plugin_options = 'obfs=tls';
        }
        if ($plugin_options != '') {
            $array_all['plugin'] = 'simple-obfs'; //目前只支持这个
            $array_all['plugin_options'] = $plugin_options;
            if ($user->obfs_param != '') {
                $array_all['plugin_options'] .= ';obfs-host=' . $user->obfs_param;
            }
        }

        $nodes_muport = Node::where('type', 1)
            ->where('sort', '=', 9)
            ->orderBy('name')
            ->get();
        $array_server = array();
        $nodes = Node::where('type', 1)
            ->where('node_class', '<=', $user->class)
            ->where(
                static function ($func) {
                    $func->where('sort', '=', 0)
                        ->orwhere('sort', '=', 10)
                        ->orwhere('sort', '=', 13);
                }
            )
            ->where(
                static function ($func) use ($user) {
                    $func->where('node_group', '=', $user->node_group)
                        ->orwhere('node_group', '=', 0);
                }
            )
            ->orderBy('name')
            ->get();
        $server_index = 1;
        foreach ($nodes as $node) {
            $server = array();
            if ($node->sort == 13) {
                if (self::CanMethodConnect($user->method) != 2) {
                    continue;
                }
                $server = Tools::ssv2Array($node->server);
                $server['server'] = $server['add'];
                $server['id'] = $server_index;
                $server['remarks'] = $node->name . ' - 单多' . $server['port'] . '端口';
                $server['encryption'] = $user->method;
                $server['password'] = $user->passwd;
                $server['plugin'] = 'v2ray';
                $server['path'] = ($server['path'] . '?redirect=' . $user->getMuMd5());
                if ($server['tls'] == 'tls' && $server['net'] == 'ws') {
                    $server['obfs_param'] = ('mode=ws;security=tls;path=' . $server['path'] .
                        ';host=' . $server['host']);
                } else {
                    $server['obfs_param'] = ('mode=ws;security=none;path=' . $server['path'] .
                        ';host=' . $server['host']);
                }
                $array_server[] = $server;
                $server_index++;
                continue;
            } else {
                $node_server = explode(';', $node->server);
                $server['server'] = $node_server[0];
            }
            $server['id'] = $server_index;
            //判断是否是中转起源节点
            $relay_rule = Relay::where('source_node_id', $node->id)->where(
                static function ($query) use ($user) {
                    $query->Where('user_id', '=', $user->id)
                        ->orWhere('user_id', '=', 0);
                }
            )->orderBy('priority', 'DESC')->orderBy('id')->first();
            if ($relay_rule != null) {
                //是中转起源节点
                $server['remarks'] = $node->name . ' => ' . $relay_rule->dist_node()->name;
                $server['ratio'] = $node->traffic_rate + $relay_rule->dist_node()->traffic_rate;
                $array_server[] = $server;
                $server_index++;
                continue;
            }

            //不是中转起源节点

            $server['ratio'] = $node->traffic_rate;
            //包含普通
            if (($node->mu_only == 0 || $node->mu_only == -1) && $node->sort != 13) {
                $server['remarks'] = $node->name;
                $array_server[] = $server;
                $server_index++;
            }
            //包含单多
            if (($node->mu_only == 0 || $node->mu_only == 1) && $node->sort != 13) {
                $nodes_muport = Node::where('type', '1')->where('sort', '=', 9)
                    ->where(static function ($query) use ($user) {
                        $query->Where('node_group', '=', $user->group)
                            ->orWhere('node_group', '=', 0);
                    })
                    ->where('node_class', '<=', $user->class)
                    ->orderBy('server')->get();
                foreach ($nodes_muport as $node_muport) {
                    $muport_user = User::where('port', '=', $node_muport->server)->first();
                    if (!self::SSCanConnect($muport_user)) {
                        continue;
                    }
                    $server['id'] = $server_index;
                    $server['remarks'] = $node->name . ' - 单多' . $node_muport->server . '端口';
                    $server['port'] = $node_muport->server;
                    // 端口偏移
                    if (strpos($node->server, ';') !== false) {
                        $node_tmp = Tools::OutPort($node->server, $node->name, $node_muport->server);
                        $server['port'] = $node_tmp['port'];
                        $server['remarks'] = $node->name . ' - 单多' . $node_tmp['port'] . '端口';
                    }
                    $server['encryption'] = $muport_user->method;
                    $server['password'] = $muport_user->passwd;
                    $server['plugin'] = 'simple-obfs'; //目前只支持这个
                    $plugin_options = '';
                    if (strpos($muport_user->obfs, 'http') != false) {
                        $plugin_options = 'obfs=http';
                    }
                    if (strpos($muport_user->obfs, 'tls') != false) {
                        $plugin_options = 'obfs=tls';
                    }
                    $server['plugin_options'] = $plugin_options . ';obfs-host=' . $user->getMuMd5();
                    $array_server[] = $server;
                    $server_index++;
                }
            }
        }

        $array_all['servers'] = $array_server;
        $json_all = json_encode($array_all);

        return 'ssd://' . Tools::base64_url_encode($json_all);
    }

    public static function getJsonObfs($item)
    {
        $ss_obfs_list = Config::getSupportParam('ss_obfs');
        $plugin = '';
        if (in_array($item['obfs'], $ss_obfs_list)) {
            if (strpos($item['obfs'], 'http') !== false) {
                $plugin .= 'obfs-local --obfs http';
            } else {
                $plugin .= 'obfs-local --obfs tls';
            }
            if ($item['obfs_param'] != '') {
                $plugin .= '--obfs-host ' . $item['obfs_param'];
            }
        }
        return $plugin;
    }

    public static function getSurgeObfs($item)
    {
        $ss_obfs_list = Config::getSupportParam('ss_obfs');
        $plugin = '';
        if (in_array($item['obfs'], $ss_obfs_list)) {
            if (strpos($item['obfs'], 'http') !== false) {
                $plugin .= ', obfs=http';
            } else {
                $plugin .= ', obfs=tls';
            }
            if ($item['obfs_param'] != '') {
                $plugin .= ', obfs-host=' . $item['obfs_param'];
            } else {
                $plugin .= ', obfs-host=wns.windows.com';
            }
        }
        return $plugin;
    }

    /*
    * Conn info
    * address
    * port
    * passwd
    * method
    * remark
    * protocol
    * protocol_param
    * obfs
    * obfs_param
    */
    public static function getItem($user, $node, $mu_port = 0, $relay_rule_id = 0, $is_ss = 0)
    {
        $relay_rule = Relay::where('id', $relay_rule_id)->where(
            static function ($query) use ($user) {
                $query->Where('user_id', '=', $user->id)
                    ->orWhere('user_id', '=', 0);
            }
        )->orderBy('priority', 'DESC')->orderBy('id')->first();
        $node_name = $node->name;
        if ($relay_rule != null) {
            $node_name .= ' - ' . $relay_rule->dist_node()->name;
        }
        if ($mu_port != 0) {
            $mu_user = User::where('port', '=', $mu_port)->where('is_multi_user', '<>', 0)->first();
            if ($mu_user == null) {
                return;
            }
            $mu_user->obfs_param = $user->getMuMd5();
            $mu_user->protocol_param = $user->id . ':' . $user->passwd;
            $user = $mu_user;
            $node_name .= ' - ' . $mu_port . ' 单端口';
        }
        if ($is_ss) {
            if (!self::SSCanConnect($user)) {
                return;
            }
            $user = self::getSSConnectInfo($user);
        } else {
            if (!self::SSRCanConnect($user)) {
                return;
            }
            $user = self::getSSRConnectInfo($user);
        }
        $return_array['address'] = $node->server;
        $return_array['port'] = $user->port;
        $return_array['protocol'] = $user->protocol;
        $return_array['protocol_param'] = $user->protocol_param;
        $return_array['obfs'] = $user->obfs;
        $return_array['obfs_param'] = $user->obfs_param;
        if (strpos($node->server, ';') !== false) {
            $node_tmp = Tools::OutPort($node->server, $node->name, $mu_port);
            if ($mu_port != 0) {
                $return_array['port'] = $node_tmp['port'];
                $node_name = $node_tmp['name'];
            }
            $return_array['address'] = $node_tmp['address'];
        }
        $return_array['passwd'] = $user->passwd;
        $return_array['method'] = $user->method;
        $return_array['remark'] = $node_name;
        $return_array['class'] = $node->node_class;
        $return_array['group'] = Config::get('appName');
        return $return_array;
    }

    public static function cloneUser($user)
    {
        return clone $user;
    }

    public static function getUserTraffic($user, $type)
    {
        $group_name = Config::get('appName');
        if (strtotime($user->expire_in) > time()) {
            if ($user->transfer_enable == 0) {
                $userTraffic = '剩余流量：0.00%';
            } else {
                $userTraffic = '剩余流量：' . number_format(($user->transfer_enable - $user->u - $user->d) / $user->transfer_enable * 100, 2) . '% ' . $user->unusedTraffic();
            }
            $userClassExpire = '过期时间：' . $user->class_expire;
        } else {
            $userTraffic = '账户已过期，请续费后使用';
            $userClassExpire = '账户已过期，请续费后使用';
        }
        switch ($type) {
            case 1: // SSR
                $getUserTraffic = 'ssr://' . Tools::base64_url_encode('www.google.com:1:auth_chain_a:chacha20:tls1.2_ticket_auth:YnJlYWt3YWxs/?obfsparam=&protoparam=&remarks=' . Tools::base64_url_encode($userTraffic) . '&group=' . Tools::base64_url_encode($group_name)) . PHP_EOL;
                $getUserClassExpiration = 'ssr://' . Tools::base64_url_encode('www.google.com:1:auth_chain_a:chacha20:tls1.2_ticket_auth:YnJlYWt3YWxs/?obfsparam=&protoparam=&remarks=' . Tools::base64_url_encode($userClassExpire) . '&group=' . Tools::base64_url_encode($group_name)) . PHP_EOL;
                break;
            case 2: // SS
                $getUserTraffic = 'ss://' . Tools::base64_url_encode('chacha20:YnJlYWt3YWxs@www.google.com:2') . '#' . rawurlencode($userTraffic) . PHP_EOL;
                $getUserClassExpiration = 'ss://' . Tools::base64_url_encode('chacha20:YnJlYWt3YWxs@www.google.com:2') . '#' . rawurlencode($userClassExpire) . PHP_EOL;
                break;
            case 3: // V2
                $userTrafficArray = ['v' => '2', 'ps' => $userTraffic, 'add' => 'www.google.com', 'port' => '3', 'id' => '2661b5f8-8062-34a5-9371-a44313a75b6b', 'aid' => '16', 'net' => 'tcp', 'type' => 'none', 'host' => '', 'tls' => ''];
                $userClassExpirationArray = ['v' => '2', 'ps' => $userClassExpire, 'add' => 'www.google.com', 'port' => '3', 'id' => '2661b5f8-8062-34a5-9371-a44313a75b6b', 'aid' => '16', 'net' => 'tcp', 'type' => 'none', 'host' => '', 'tls' => ''];
                $getUserTraffic = 'vmess://' . base64_encode(json_encode($userTrafficArray, JSON_UNESCAPED_UNICODE)) . PHP_EOL;
                $getUserClassExpiration = 'vmess://' . base64_encode(json_encode($userClassExpirationArray, JSON_UNESCAPED_UNICODE)) . PHP_EOL;
                break;
        }
        return $getUserTraffic . $getUserClassExpiration;
    }
}
