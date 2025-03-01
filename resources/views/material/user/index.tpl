{include file='user/main.tpl'}
{$ssr_prefer = URL::SSRCanConnect($user, 0)}
{$pre_user = URL::cloneUser($user)}

<style>
.table {
    box-shadow: none;
}
table tr td:first-child {
    text-align: right;
    font-weight: bold;
}
</style>

<main class="content">

    <div class="content-header ui-content-header">
        <div class="container">
            <h1 class="content-heading">用户中心</h1>
        </div>
    </div>
    <div class="container">
        <section class="content-inner margin-top-no">
            <div class="ui-card-wrap">

                <div class="col-xx-12 col-xs-6 col-lg-3">
                    <div class="card user-info">
                        <div class="user-info-main">
                            <div class="nodemain">
                                <div class="nodehead node-flex">
                                    <div class="nodename">帐号等级</div>
                                </div>
                                <div class="nodemiddle node-flex">
                                    <div class="nodetype">
                                        {if $user->class!=0}
                                            <dd>VIP {$user->class}</dd>
                                        {else}
                                            <dd>普通用户</dd>
                                        {/if}
                                    </div>
                                </div>
                                <div class="nodemiddle node-flex">
                                    {if $user->class_expire!="1989-06-04 00:05:00"}
                                        <div style="font-size: 14px">等级到期时间 {$user->class_expire}</div>
                                    {else}
                                        <div style="font-size: 14px">账户等级不会过期</div>
                                    {/if}
                                </div>
                            </div>
                        </div>
                        <div class="user-info-bottom">
                            <div class="nodeinfo node-flex">
                                {if $user->class!=0}
                                    <span><i class="icon icon-md">add_circle</i>到期流量清空</span>
                                {else}
                                    <span><i class="icon icon-md">add_circle</i>升级解锁 VIP 节点</span>
                                {/if}
                                <a href="/user/shop" class="card-tag tag-orange">商店</a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xx-12 col-xs-6 col-lg-3">
                    <div class="card user-info">
                        <div class="user-info-main">
                            <div class="nodemain">
                                <div class="nodehead node-flex">
                                    <div class="nodename">余额</div>
                                </div>
                                <div class="nodemiddle node-flex">
                                    <div class="nodetype">
                                        {$user->money} CNY
                                    </div>
                                </div>
                                <div class="nodemiddle node-flex">
                                    <div style="font-size: 14px">账户有效时间 {$user->expire_in}</div>
                                </div>
                            </div>
                        </div>
                        <div class="user-info-bottom">
                            <div class="nodeinfo node-flex">
                                <span><i class="icon icon-md">attach_money</i>到期账户自动删除</span>
                                <a href="/user/code" class="card-tag tag-green">充值</a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xx-12 col-xs-6 col-lg-3">
                    <div class="card user-info">
                        <div class="user-info-main">
                            <div class="nodemain">
                                <div class="nodehead node-flex">
                                    <div class="nodename">在线设备数</div>
                                </div>
                                <div class="nodemiddle node-flex">
                                    <div class="nodetype">
                                        {if $user->node_connector!=0}
                                            <dd>{$user->online_ip_count()} / {$user->node_connector}</dd>
                                        {else}
                                            <dd>{$user->online_ip_count()} / 不限制</dd>
                                        {/if}
                                    </div>
                                </div>
                                <div class="nodemiddle node-flex">
                                    {if $user->lastSsTime()!="从未使用喵"}
                                        <div style="font-size: 14px">上次使用：{$user->lastSsTime()}</div>
                                    {else}
                                        <div style="font-size: 14px">从未使用过</div>
                                    {/if}
                                </div>
                            </div>
                        </div>
                        <div class="user-info-bottom">
                            <div class="nodeinfo node-flex">
                                <span><i class="icon icon-md">donut_large</i>在线设备/设备限制数</span>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xx-12 col-xs-6 col-lg-3">
                    <div class="card user-info">
                        <div class="user-info-main">
                            <div class="nodemain">
                                <div class="nodehead node-flex">
                                    <div class="nodename">端口速率</div>
                                </div>
                                <div class="nodemiddle node-flex">
                                    <div class="nodetype">
                                        {if $user->node_speedlimit!=0}
                                            <dd><code>{$user->node_speedlimit}</code>Mbps</dd>
                                        {else}
                                            <dd>无限制</dd>
                                        {/if}
                                    </div>
                                </div>
                                <div class="nodemiddle node-flex">
                                    <div style="font-size: 14px">实际速率受限于运营商带宽上限</div>
                                </div>
                            </div>
                        </div>
                        <div class="user-info-bottom">
                            <div class="nodeinfo node-flex">
                                <span><i class="icon icon-md">signal_cellular_alt</i>账户最高下行网速</span>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
            <div class="ui-card-wrap">

                <div class="col-xx-12 col-sm-5">

				{if $user->detect_ban==1}
                    <div class="card">
                        <div class="card-main">
                            <div class="card-inner margin-bottom-no">
                                <p class="card-heading"><i class="icon icon-md">account_circle</i>账户违规</p>
							{if $user->user_detect_ban_number()==0}
								<p><strong>您好，您的账户因触碰了审计规则或其他原因，目前被暂停使用</strong></p>
							{else}
								<p><strong>您好，您的账户因触碰了 {$user->user_detect_ban_number()} 次审计规则，目前被暂停使用</strong></p>
							{/if}
							    <p><strong>解除时间：{$user->relieve_time()}</strong></p>
                            </div>
                        </div>
                    </div>
                {/if}

                    <div class="card">
                        <div class="card-main">
                        <div class="card-inner margin-bottom-no">
                            <p class="card-heading" style="margin-bottom: 0;"><i class="icon icon-md">account_circle</i>流量使用情况</p>
                                <div class="progressbar">
                                    <div class="before"></div>
                                    <div class="bar tuse color3"
                                         style="width:calc({($user->transfer_enable==0)?0:($user->u+$user->d-$user->last_day_t)/$user->transfer_enable*100}%);"></div>
                                    <div class="label-flex">
                                        <div class="label la-top">
                                            <div class="bar ard color3"></div>
                                            <span class="traffic-info">今日已用</span>
                                            <code class="card-tag tag-red">{$user->TodayusedTraffic()}</code>
                                        </div>
                                    </div>
                                </div>
                                <div class="progressbar">
                                    <div class="before"></div>
                                    <div class="bar ard color2"
                                         style="width:calc({($user->transfer_enable==0)?0:$user->last_day_t/$user->transfer_enable*100}%);">
                                        <span></span>
                                    </div>
                                    <div class="label-flex">
                                        <div class="label la-top">
                                            <div class="bar ard color2"><span></span></div>
                                            <span class="traffic-info">过去已用</span>
                                            <code class="card-tag tag-orange">{$user->LastusedTraffic()}</code>
                                        </div>
                                    </div>
                                </div>
                                <div class="progressbar">
                                    <div class="before"></div>
                                    <div class="bar remain color"
                                         style="width:calc({($user->transfer_enable==0)?0:($user->transfer_enable-($user->u+$user->d))/$user->transfer_enable*100}%);">
                                        <span></span>
                                    </div>
                                    <div class="label-flex">
                                        <div class="label la-top">
                                            <div class="bar ard color"><span></span></div>
                                            <span class="traffic-info">剩余流量</span>
                                            <code class="card-tag tag-green" id="remain">{$user->unusedTraffic()}</code>
                                        </div>
                                    </div>
                                </div>

                            </div>

                            <div class="card-inner margin-bottom-no">
                                <p class="card-heading"><i class="icon icon-md">account_circle</i>签到</p>

                                    <p>上次签到时间：{$user->lastCheckInTime()}</p>

                                    <p id="checkin-msg"></p>

                                    {if $geetest_html != null}
                                        <div id="popup-captcha"></div>
                                    {/if}
                                    {if $recaptcha_sitekey != null && $user->isAbleToCheckin()}
                                        <div class="g-recaptcha" data-sitekey="{$recaptcha_sitekey}"></div>
                                    {/if}

                                    <div class="card-action">
                                        <div class="usercheck pull-left">
                                            {if $user->isAbleToCheckin() }
                                                <div id="checkin-btn">
                                                    <button id="checkin" class="btn btn-brand btn-flat"><span
                                                                class="icon">check</span>&nbsp;点我签到&nbsp;
                                                        <div><span class="icon">screen_rotation</span>&nbsp;或者摇动手机签到
                                                        </div>
                                                    </button>
                                                </div>
                                            {else}
                                                <p><a class="btn btn-brand disabled btn-flat" href="#"><span
                                                                class="icon">check</span>&nbsp;今日已签到</a></p>
                                            {/if}
                                        </div>
                                    </div>
                                </dl>
                            </div>

                        </div>
                    </div>

                    <div class="card">
                        <div class="card-main">
                            <div class="card-inner margin-bottom-no">
                                <p class="card-heading"><i class="icon icon-md">notifications_active</i>公告栏</p>
                                {if $ann != null}
                                    <p>{$ann->content}</p>
                                    <br/>
                                    <strong>查看所有公告请<a href="/user/announcement">点击这里</a></strong>
                                {/if}
                                {if $config["enable_admin_contact"] == 'true'}
                                    <p class="card-heading">管理员联系方式</p>
                                    {if $config["admin_contact1"]!=null}
                                        <p>{$config["admin_contact1"]}</p>
                                    {/if}
                                    {if $config["admin_contact2"]!=null}
                                        <p>{$config["admin_contact2"]}</p>
                                    {/if}
                                    {if $config["admin_contact3"]!=null}
                                        <p>{$config["admin_contact3"]}</p>
                                    {/if}
                                {/if}
                            </div>
                        </div>
                    </div>

                </div>

                <div class="col-xx-12 col-sm-7">

                    <div class="card quickadd">
                        <div class="card-main">
                            <div class="card-inner">
                                <div class="cardbtn-edit">
                                    <div class="card-heading"><i class="icon icon-md">phonelink</i> 快速使用</div>
                                </div>

								<nav class="tab-nav margin-top-no">
									<ul class="nav nav-list">
										<li class="active">
											<a class="" data-toggle="tab" href="#sub_center"><i class="icon icon-lg">info_outline</i>&nbsp;订阅中心</a>
										</li>
										<li>
											<a class="" data-toggle="tab" href="#info_center"><i class="icon icon-lg">flight_takeoff</i>&nbsp;连接信息</a>
										</li>
									</ul>
								</nav>

								<div class="card-inner">
									<div class="tab-content">

										<div class="tab-pane fade" id="info_center">
											<p>您的链接信息：</p>

											{if URL::SSRCanConnect($user)}

												{$user = URL::getSSRConnectInfo($pre_user)}
                                                <table class="table">
                                                    <tbody>
                                                        <tr>
                                                            <td><strong>端口</strong></td>
                                                            <td>{$user->port}</td>
                                                        </tr>
                                                        <tr>
                                                            <td><strong>密码</strong></td>
                                                            <td>{$user->passwd}</td>
                                                        </tr>
                                                        <tr>
                                                            <td><strong>自定义加密</strong></td>
                                                            <td>{$user->method}</td>
                                                        </tr>
                                                        <tr>
                                                            <td><strong>自定义协议</strong></td>
                                                            <td>{$user->protocol}</td>
                                                        </tr>
                                                        <tr>
                                                            <td><strong>自定义混淆</strong></td>
                                                            <td>{$user->obfs}</td>
                                                        </tr>
                                                        <tr>
                                                            <td><strong>自定义混淆参数</strong></td>
                                                            <td>{$user->obfs_param}</td>
                                                        </tr>
                                                    </tbody>
                                                </table>
												<hr/>
												<p>您好，您目前的 加密方式，混淆或协议 为 SSR 模式，请您选用支持 SSR 的客户端来连接，或者到 <a href="/user/edit">资料编辑</a> 页面修改后再来查看此处。</p>
                                                <p>同时, ShadowsocksR 单端口多用户的连接不受您设置的影响，您可以在此使用相应的客户端进行连接</p>

											{elseif URL::SSCanConnect($user)}

                                                {$user = URL::getSSConnectInfo($pre_user)}
                                                <table class="table">
                                                    <tbody>
                                                        <tr>
                                                            <td><strong>端口</strong></td>
                                                            <td>{$user->port}</td>
                                                        </tr>
                                                        <tr>
                                                            <td><strong>密码</strong></td>
                                                            <td>{$user->passwd}</td>
                                                        </tr>
                                                        <tr>
                                                            <td><strong>自定义加密</strong></td>
                                                            <td>{$user->method}</td>
                                                        </tr>
                                                        <tr>
                                                            <td><strong>自定义混淆</strong></td>
                                                            <td>{$user->obfs}</td>
                                                        </tr>
                                                        <tr>
                                                            <td><strong>自定义混淆参数</strong></td>
                                                            <td>{$user->obfs_param}</td>
                                                        </tr>
                                                    </tbody>
                                                </table>
												<hr/>
                                                <p>您好，您目前的 加密方式，混淆或协议 为 SS 模式，请您选用支持 SS 协议的客户端来连接，或者到 <a href="/user/edit">资料编辑</a> 页面修改后再来查看此处。</p>
                                                <p>同时, Shadowsocks 单端口多用户的连接不受您设置的影响，您可以在此使用相应的客户端进行连接</p>

                                            {else}

                                                <p>您的账户连接信息存在异常，请联系管理员</p>

											{/if}

										</div>

										<div class="tab-pane fade active in" id="sub_center">
											<nav class="tab-nav margin-top-no">
												<ul class="nav nav-list">
													<li class="active">
														<a class="" data-toggle="tab" href="#sub_center_general"><i class="icon icon-lg">desktop_windows</i>&nbsp;General</a>
													</li>
													<li>
														<a class="" data-toggle="tab" href="#sub_center_windows"><i class="icon icon-lg">desktop_windows</i>&nbsp;Windows</a>
													</li>
													<li>
														<a class="" data-toggle="tab" href="#sub_center_mac"><i class="icon icon-lg">laptop_mac</i>&nbsp;MacOS</a>
													</li>
													<li>
														<a class="" data-toggle="tab" href="#sub_center_ios"><i class="icon icon-lg">phone_iphone</i>&nbsp;iOS</a>
													</li>
													<li>
														<a class="" data-toggle="tab" href="#sub_center_android"><i class="icon icon-lg">android</i>&nbsp;Android</a>
													</li>
												</ul>
											</nav>

											<div class="tab-pane fade active in" id="sub_center_general">
												<p><span class="icon icon-lg text-white">filter_1</span> [ SS ]：
													<a id="general_ss" class="copy-config btn-dl" onclick=Copyconfig("/user/getUserAllURL?type=ss","#general_ss","")><i class="material-icons icon-sm">how_to_vote</i>全部 URL</a>
												</p>
												<hr/>
												<p><span class="icon icon-lg text-white">filter_2</span> [ SSR ]：
													<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["ssr"]}&extend=1"><i class="material-icons icon-sm">how_to_vote</i>订阅链接</a>.<a id="general_ssr" class="copy-config btn-dl" onclick=Copyconfig("/user/getUserAllURL?type=ssr","#general_ssr","")><i class="material-icons icon-sm">how_to_vote</i>全部 URL</a>
												</p>
												<hr/>
												<p><span class="icon icon-lg text-white">filter_3</span> [ VMess ]：
													<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["v2ray"]}&extend=1"><i class="material-icons icon-sm">how_to_vote</i>订阅链接</a>.<a id="general_v2ray" class="copy-config btn-dl" onclick=Copyconfig("/user/getUserAllURL?type=v2ray","#general_v2ray","")><i class="material-icons icon-sm">how_to_vote</i>全部 URL</a>
												</p>
											</div>

											<div class="tab-pane fade" id="sub_center_windows">
												<p><span class="icon icon-lg text-white">filter_1</span> <a class="btn-dl" href="https://github.com/CGDF-Github/SSD-Windows/releases"><i class="material-icons">save_alt</i> 下载</a> SSD - [ SS ]：</p>
													<p>教程文档：<a class="btn-dl" href="/doc/#/Windows/ShadowsocksD"><i class="material-icons icon-sm">how_to_vote</i>点击查看</a></p>
													<p>使用方式：<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["ssd"]}"><i class="material-icons icon-sm">how_to_vote</i>拷贝链接</a>.<a id="win_ssd" class="copy-config btn-dl" onclick=Copyconfig("/user/getUserAllURL?type=ssd","#win_ssd","")><i class="material-icons icon-sm">how_to_vote</i>全部 URL</a></p>
												<hr/>
												<p><span class="icon icon-lg text-white">filter_2</span> <a class="btn-dl" href="https://github.com/Fndroid/clash_for_windows_pkg/releases"><i class="material-icons">save_alt</i> 下载</a> Clash for Windows - [ SS/VMess ]：</p>
													<p>教程文档：<a class="btn-dl" href="/doc/#/Windows/Clash-for-Windows"><i class="material-icons icon-sm">how_to_vote</i>点击查看</a></p>
													<p>使用方式：<a class="btn-dl" href="{$subInfo["clash"]}"><i class="material-icons icon-sm">how_to_vote</i>配置下载</a>.<a class="btn-dl" href="clash://install-config?url={urlencode($subInfo["clash"])}"><i class="material-icons icon-sm">how_to_vote</i>Clash for Windows 一键导入</a></p>
											</div>

											<div class="tab-pane fade" id="sub_center_mac">
												<p><span class="icon icon-lg text-white">filter_1</span> <a class="btn-dl" href="https://nssurge.com/mac/v3/Surge-latest.zip"><i class="material-icons">save_alt</i> 下载</a> Surge - [ SS ]：</p>
													<p>教程文档：<a class="btn-dl" href="/doc/#/macOS/Surge"><i class="material-icons icon-sm">how_to_vote</i>点击查看</a></p>
													<p>使用方式：<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["surge3"]}"><i class="material-icons icon-sm">how_to_vote</i>3.x 托管</a>.<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["surge_node"]}"><i class="material-icons icon-sm">how_to_vote</i>3.x 节点</a>.<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["surge2"]}"><i class="material-icons icon-sm">how_to_vote</i>2.x 托管</a></p>
												<hr/>
												<p><span class="icon icon-lg text-white">filter_2</span> <a class="btn-dl" href="https://github.com/yichengchen/clashX/releases"><i class="material-icons">save_alt</i> 下载</a> ClashX - [ SS/VMess ]：</p>
													<p>教程文档：<a class="btn-dl" href="/doc/#/macOS/ClashX"><i class="material-icons icon-sm">how_to_vote</i>点击查看</a></p>
													<p>使用方式：<a class="btn-dl" href="{$subInfo["clash"]}"><i class="material-icons icon-sm">how_to_vote</i>配置下载</a>.<a class="btn-dl" href="clash://install-config?url={urlencode($subInfo["clash"])}"><i class="material-icons icon-sm">how_to_vote</i>ClashX 一键导入</a></p>
											</div>

											<div class="tab-pane fade" id="sub_center_ios">
											{if $display_ios_class>=0}
												{if $user->class>=$display_ios_class && $user->get_top_up()>=$display_ios_topup}
												<div><span class="icon icon-lg text-white">account_box</span> 本站iOS账户：</div>
												<div class="float-clear">
													<input type="text" class="input form-control form-control-monospace cust-link col-xx-12 col-sm-8 col-lg-7" name="input1" readonly value="{$ios_account}" readonly="true">
													<button class="copy-text btn btn-subscription col-xx-12 col-sm-3 col-lg-2" type="button" data-clipboard-text="{$ios_account}">点击复制</button>
                                                    <br>
												</div>
												<div><span class="icon icon-lg text-white">lock</span> 本站iOS密码：</div>
												<div class="float-clear">
													<input type="text" class="input form-control form-control-monospace cust-link col-xx-12 col-sm-8 col-lg-7" name="input1" readonly value="{$ios_password}" readonly="true">
													<button class="copy-text btn btn-subscription col-xx-12 col-sm-3 col-lg-2" type="button" data-clipboard-text="{$ios_password}">点击复制</button>
                                                    <br>
												</div>
												<p><span class="icon icon-lg text-white">error</span><strong>禁止将账户分享给他人！</strong></p>
												<hr/>
												{/if}
											{/if}
												<p><span class="icon icon-lg text-white">filter_1</span> <a class="btn-dl" href="https://itunes.apple.com/us/app/surge-3/id1442620678?ls=1&mt=8"><i class="material-icons">save_alt</i> 下载</a> Surge - [ SS ]：</p>
													<p>教程文档：<a class="btn-dl" href="/doc/#/iOS/Surge"><i class="material-icons icon-sm">how_to_vote</i>点击查看</a></p>
													<p>使用方式：<a class="btn-dl" href="surge3:///install-config?url={urlencode($subInfo["surge3"])}"><i class="material-icons icon-sm">how_to_vote</i>3.x 一键</a>.<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["surge_node"]}"><i class="material-icons icon-sm">how_to_vote</i>3.x 节点</a>.<a class="btn-dl" href="surge:///install-config?url={urlencode($subInfo["surge2"])}"><i class="material-icons icon-sm">how_to_vote</i>2.x 一键</a></p>
												<hr/>
												<p><span class="icon icon-lg text-white">filter_2</span> <a class="btn-dl" href="https://itunes.apple.com/us/app/kitsunebi-proxy-utility/id1446584073?ls=1&mt=8"><i class="material-icons">save_alt</i> 下载</a> Kitsunebi - [ SS/VMess ]：</p>
													<p>教程文档：<a class="btn-dl" href="/doc/#/iOS/Kitsunebi"><i class="material-icons icon-sm">how_to_vote</i>点击查看</a></p>
													<p>使用方式：<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["kitsunebi"]}&extend=1"><i class="material-icons icon-sm">how_to_vote</i>SS + V2 混合订阅</a></p>
												<hr/>
												<p><span class="icon icon-lg text-white">filter_3</span> <a class="btn-dl" href="https://itunes.apple.com/us/app/quantumult/id1252015438?ls=1&mt=8"><i class="material-icons">save_alt</i> 下载</a> Quantumult - [ SS/SSR/VMess ]：</p>
													<p>教程文档：<a class="btn-dl" href="/doc/#/iOS/Quantumult_sub"><i class="material-icons icon-sm">how_to_vote</i>点击查看</a></p>
													<p>使用方式：<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["quantumult_v2"]}"><i class="material-icons icon-sm">how_to_vote</i>V2 订阅</a>.<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["ssr"]}&extend=1"><i class="material-icons icon-sm">how_to_vote</i>SSR 订阅</a>.<a id="quan_sub" class="copy-config btn-dl" onclick=Copyconfig("{$subInfo["quantumult_sub"]}","#quan_sub","quantumult://settings?configuration=clipboard")><i class="material-icons icon-sm">how_to_vote</i>完整订阅配置</a>.<a id="quan_conf" class="copy-config btn-dl" onclick=Copyconfig("{$subInfo["quantumult_conf"]}","#quan_conf","quantumult://settings?configuration=clipboard")><i class="material-icons icon-sm">how_to_vote</i>完整策略组配置</a></p>
												<hr/>
												<p><span class="icon icon-lg text-white">filter_4</span> <a class="btn-dl" href="https://itunes.apple.com/us/app/shadowrocket/id932747118?mt=8"><i class="material-icons">save_alt</i> 下载</a> Shadowrocket - [ SS/SSR/VMess ]：</p>
													<p>教程文档：<a class="btn-dl" href="/doc/#/iOS/Shadowrocket"><i class="material-icons icon-sm">how_to_vote</i>点击查看</a></p>
													<p>使用方式：<a class="btn-dl" onclick=AddSub("{$subInfo["shadowrocket"]}","sub://")><i class="material-icons icon-sm">how_to_vote</i>SS(R) + V2 混合订阅</a></p>
											</div>

											<div class="tab-pane fade" id="sub_center_android">
												<p><span class="icon icon-lg text-white">filter_1</span> <a class="btn-dl" href="https://github.com/CGDF-Github/SSD-Android/releases"><i class="material-icons">save_alt</i> 下载</a> SSD - [ SS ]：</p>
													<p>教程文档：<a class="btn-dl" href="/doc/#/Android/ShadowsocksD"><i class="material-icons icon-sm">how_to_vote</i>点击查看</a></p>
													<p>使用方式：<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["ssd"]}"><i class="material-icons icon-sm">how_to_vote</i>拷贝链接</a>.<a id="android_ssd" class="copy-config btn-dl" onclick=Copyconfig("/user/getUserAllURL?type=ssd","#android_ssd","")><i class="material-icons icon-sm">how_to_vote</i>全部 URL</a></p>
												<hr/>
												<p><span class="icon icon-lg text-white">filter_2</span> <a class="btn-dl" href="#"><i class="material-icons">save_alt</i> 下载</a> SSR - [ SSR ]：</p>
													<p>教程文档：<a class="btn-dl" href="/doc/#/Android/ShadowsocksR"><i class="material-icons icon-sm">how_to_vote</i>点击查看</a></p>
													<p>使用方式：<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["ssr"]}&extend=1"><i class="material-icons icon-sm">how_to_vote</i>拷贝链接</a></p>
												<hr/>
												<p><span class="icon icon-lg text-white">filter_3</span> <a class="btn-dl" href="https://github.com/2dust/v2rayNG/releases"><i class="material-icons">save_alt</i> 下载</a> V2rayNG - [ SS/VMess ]：</p>
													<p>教程文档：<a class="btn-dl" href="/doc/#/Android/v2rayNG"><i class="material-icons icon-sm">how_to_vote</i>点击查看</a></p>
													<p>使用方式：<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["v2ray"]}&extend=1"><i class="material-icons icon-sm">how_to_vote</i>拷贝链接</a></p>
												<hr/>
												<p><span class="icon icon-lg text-white">filter_4</span> <a class="btn-dl" href="https://rink.hockeyapp.net/recruit/2113783c503645abb0a5ec6317e1a169"><i class="material-icons">save_alt</i> 下载</a> Surfboard - [ SS ]：</p>
													<p>教程文档：<a class="btn-dl" href="/doc/#/Android/Surfboard"><i class="material-icons icon-sm">how_to_vote</i>点击查看</a></p>
													<p>使用方式：<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["surfboard"]}"><i class="material-icons icon-sm">how_to_vote</i>拷贝托管</a>.<a class="btn-dl" href="{$subInfo["surfboard"]}"><i class="material-icons icon-sm">how_to_vote</i>配置下载</a></p>
												<hr/>
												<p><span class="icon icon-lg text-white">filter_5</span> <a class="btn-dl" href="https://play.google.com/store/apps/details?id=fun.kitsunebi.kitsunebi4android&hl=zh"><i class="material-icons">save_alt</i> 下载</a> Kitsunebi - [ SS/VMess ]：</p>
													<p>教程文档：<a class="btn-dl" href="/doc/#/Android/Kitsunebi"><i class="material-icons icon-sm">how_to_vote</i>点击查看</a></p>
													<p>使用方式：<a class="copy-text btn-dl" data-clipboard-text="{$subInfo["kitsunebi"]}&extend=1"><i class="material-icons icon-sm">how_to_vote</i>SS + V2 混合订阅</a></p>
											</div>
										</div>

									</div>
								</div>

                            </div>

                        </div>
                    </div>

                </div>

            </div>
            {include file='dialog.tpl'}

        </section>
    </div>
</main>


{include file='user/footer.tpl'}

<script src="https://cdn.jsdelivr.net/npm/shake.js@1.2.2/shake.min.js"></script>

<script>

    function DateParse(str_date) {
        var str_date_splited = str_date.split(/[^0-9]/);
        return new Date(str_date_splited[0], str_date_splited[1] - 1, str_date_splited[2], str_date_splited[3], str_date_splited[4], str_date_splited[5]);
    }

    /*
     * Author: neoFelhz & CloudHammer
     * https://github.com/CloudHammer/CloudHammer/make-sspanel-v3-mod-great-again
     * License: MIT license & SATA license
     */
    function CountDown() {
        var levelExpire = DateParse("{$user->class_expire}");
        var accountExpire = DateParse("{$user->expire_in}");
        var nowDate = new Date();
        var a = nowDate.getTime();
        var b = levelExpire - a;
        var c = accountExpire - a;
        var levelExpireDays = Math.floor(b / (24 * 3600 * 1000));
        var accountExpireDays = Math.floor(c / (24 * 3600 * 1000));
        if (levelExpireDays < 0 || levelExpireDays > 315360000000) {
            document.getElementById('days-level-expire').innerHTML = "无限期";
            for (var i = 0; i < document.getElementsByClassName('label-level-expire').length; i += 1) {
                document.getElementsByClassName('label-level-expire')[i].style.display = 'none';
            }
        } else {
            document.getElementById('days-level-expire').innerHTML = levelExpireDays;
        }
        if (accountExpireDays < 0 || accountExpireDays > 315360000000) {
            document.getElementById('days-account-expire').innerHTML = "无限期";
            for (var i = 0; i < document.getElementsByClassName('label-account-expire').length; i += 1) {
                document.getElementsByClassName('label-account-expire')[i].style.display = 'none';
            }
        } else {
            document.getElementById('days-account-expire').innerHTML = accountExpireDays;
        }
    }
</script>

<script>

    $(function(){
	    new Clipboard('.copy-text');
    });

    $(".copy-text").click(function () {
        $("#result").modal();
        $$.getElementById('msg').innerHTML = '已复制，请您继续接下来的操作';
    });

    function AddSub(url,jumpurl="") {
	    let tmp = window.btoa(url);
	    window.location.href = jumpurl + tmp;
    }

    function Copyconfig(url,id,jumpurl="") {
        $.ajax({
            url: url,
            type: 'get',
            async: false,
            success: function(res) {
                if(res) {
                    $("#result").modal();
                    $("#msg").html("获取成功");
                    $(id).data('data', res);
		    		console.log(res);
                } else {
                    $("#result").modal();
                   $("#msg").html("获取失败，请稍后再试");
               }
            }
        });
        const clipboard = new Clipboard('.copy-config', {
            text: function() {
                return $(id).data('data');
            }
        });
        clipboard.on('success', function(e) {
				    $("#result").modal();
				    if (jumpurl != "") {
					    $("#msg").html("复制成功，即将跳转到 APP");
					    window.setTimeout(function () {
						    window.location.href = jumpurl;
					    }, 1000);

				    } else {
					    $("#msg").html("复制成功");
				    }
			    }
        );
        clipboard.on("error",function(e){
		    console.error('Action:', e.action);
		    console.error('Trigger:', e.trigger);
		    console.error('Text:', e.text);
			}
	    );
    }

{if $user->transfer_enable-($user->u+$user->d) == 0}
    window.onload = function () {
        $("#result").modal();
        $$.getElementById('msg').innerHTML = '您的流量已经用完或账户已经过期了，如需继续使用，请进入商店选购新的套餐~';
    };
{/if}

{if $geetest_html == null}

    var checkedmsgGE = '<p><a class="btn btn-brand disabled btn-flat waves-attach" href="#"><span class="icon">check</span>&nbsp;已签到</a></p>';
    window.onload = function () {
        var myShakeEvent = new Shake({
            threshold: 15
        });
        myShakeEvent.start();
        CountDown();

        window.addEventListener('shake', shakeEventDidOccur, false);
        function shakeEventDidOccur() {
            if ("vibrate" in navigator) {
                navigator.vibrate(500);
            }
            $.ajax({
                type: "POST",
                url: "/user/checkin",
                dataType: "json",{if $recaptcha_sitekey != null}
                data: {
                    recaptcha: grecaptcha.getResponse()
                },{/if}
                success: (data) => {
                    if (data.ret) {

                        $$.getElementById('checkin-msg').innerHTML = data.msg;
                        $$.getElementById('checkin-btn').innerHTML = checkedmsgGE;
                        $("#result").modal();
                        $$.getElementById('msg').innerHTML = data.msg;
                        $$.getElementById('remain').innerHTML = data.traffic;
                        $('.bar.remain.color').css('width', (data.unflowtraffic - ({$user->u}+{$user->d})) / data.unflowtraffic * 100 + '%');
                    } else {
                        $("#result").modal();
                        $$.getElementById('msg').innerHTML = data.msg;
                    }
                },
                error: (jqXHR) => {
                    $("#result").modal();
                    $$.getElementById('msg').innerHTML = `发生错误：${
                            jqXHR.status
                            }`;
                }
            });
        }
    };

    $(document).ready(function () {
        $("#checkin").click(function () {
            $.ajax({
                type: "POST",
                url: "/user/checkin",
                dataType: "json",{if $recaptcha_sitekey != null}
                data: {
                    recaptcha: grecaptcha.getResponse()
                },{/if}
                success: (data) => {
                    if (data.ret) {
                        $$.getElementById('checkin-msg').innerHTML = data.msg;
                        $$.getElementById('checkin-btn').innerHTML = checkedmsgGE;
                        $("#result").modal();
                        $$.getElementById('msg').innerHTML = data.msg;
                        $$.getElementById('remain').innerHTML = data.traffic;
                        $('.bar.remain.color').css('width', (data.unflowtraffic - ({$user->u}+{$user->d})) / data.unflowtraffic * 100 + '%');
                    } else {
                        $("#result").modal();
                        $$.getElementById('msg').innerHTML = data.msg;
                    }
                },
                error: (jqXHR) => {
                    $("#result").modal();
                    $$.getElementById('msg').innerHTML = `发生错误：${
                            jqXHR.status
                            }`;
                }
            })
        })
    })

{else}

    window.onload = function () {
        var myShakeEvent = new Shake({
            threshold: 15
        });
        myShakeEvent.start();
        window.addEventListener('shake', shakeEventDidOccur, false);
        function shakeEventDidOccur() {
            if ("vibrate" in navigator) {
                navigator.vibrate(500);
            }
            c.show();
        }
    };

    var handlerPopup = function (captchaObj) {
        c = captchaObj;
        captchaObj.onSuccess(function () {
            var validate = captchaObj.getValidate();
            $.ajax({
                url: "/user/checkin", // 进行二次验证
                type: "post",
                dataType: "json",
                data: {
                    // 二次验证所需的三个值
                    geetest_challenge: validate.geetest_challenge,
                    geetest_validate: validate.geetest_validate,
                    geetest_seccode: validate.geetest_seccode
                },
                success: (data) => {
                    if (data.ret) {
                        $$.getElementById('checkin-msg').innerHTML = data.msg;
                        $$.getElementById('checkin-btn').innerHTML = checkedmsgGE;
                        $("#result").modal();
                        $$.getElementById('msg').innerHTML = data.msg;
                        $$.getElementById('remain').innerHTML = data.traffic;
                        $('.bar.remain.color').css('width', (data.unflowtraffic - ({$user->u}+{$user->d})) / data.unflowtraffic * 100 + '%');
                    } else {
                        $("#result").modal();
                        $$.getElementById('msg').innerHTML = data.msg;
                    }
                },
                error: (jqXHR) => {
                    $("#result").modal();
                    $$.getElementById('msg').innerHTML = `发生错误：${
                            jqXHR.status
                            }`;
                }
            });
        });
        // 弹出式需要绑定触发验证码弹出按钮
        //captchaObj.bindOn("#checkin")
        // 将验证码加到id为captcha的元素里
        captchaObj.appendTo("#popup-captcha");
        // 更多接口参考：http://www.geetest.com/install/sections/idx-client-sdk.html
    };

    initGeetest({
        gt: "{$geetest_html->gt}",
        challenge: "{$geetest_html->challenge}",
        product: "popup", // 产品形式，包括：float，embed，popup。注意只对PC版验证码有效
        offline: {if $geetest_html->success}0{else}1{/if} // 表示用户后台检测极验服务器是否宕机，与SDK配合，用户一般不需要关注
    }, handlerPopup);

{/if}

</script>

{if $recaptcha_sitekey != null}
    <script src="https://recaptcha.net/recaptcha/api.js" async defer></script>
{/if}
