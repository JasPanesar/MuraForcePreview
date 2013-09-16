<!---Copyright 2013 Blue River Interactive

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
--->
<cfscript>

if( !(isDefined('url.siteid')  &&  isDefined('url.contenthistid'))){
	location(url="../admin/",addToken=false);
}

param name="url.approve" default=false;
param name="url.compactDisplay" default=false;
param name="url.changesetid" default='';

$=application.serviceFactory.getBean('$').init(url.siteid);


if(!$.currentUser().isLoggedIn()){
	location(url="../admin/",addToken=false);
}


content=$.getBean('content').loadBy(contenthistid=url.contenthistid);
requiresApproval=content.requiresApproval();

if(requiresApproval){
	actionLabel="Send for Approval";
} else {
	actionLabel="Approve";
}
perm=$.getBean('permUtility').getNodePerm(content.getCrumbArray());

if(url.approve && perm== 'editor' ){
	content
		.setForcePreview(false)
		.setApproved(1)
		.setChangesetID(url.changesetid)
		.save();
	session.topid=content.getContentID();

	if(url.compactDisplay !='true'){
	location(url="../../admin/?muraAction=cArch.list&moduleid=00000000000000000000000000000000000&siteid=#content.getSiteID()#&activeTab=0");
	} else {
		request.event=$.event();
		rc={homeid='',
			preview=0,
			contentBean=content,
			action='add'};
		savecontent variable='body'{
			include '../../admin/core/views/carch/dsp_close_compact_display.cfm';
		}
		writeOutput(body);
		abort;
	}
}
</cfscript>
<html lang="en_US" class="mura">
<cfoutput>
<head>	
	<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <meta charset="utf-8">

    <!-- Spinner JS -->
	<script src="#application.configBean.getContext()#/admin/assets/js/spin.min.js" type="text/javascript"></script>

    <script src="#application.configBean.getContext()#/#application.settingsmanager.getSite(session.siteid).getDisplayPoolID()#/js/jquery/jquery.js" type="text/javascript"></script>
	<script src="#application.configBean.getContext()#/admin/assets/js/jquery/jquery.collapsibleCheckboxTree.js?coreversion=#application.coreversion#" type="text/javascript"></script>
	<script src="#application.configBean.getContext()#/admin/assets/js/porthole/porthole.min.js?coreversion=#application.coreversion#" type="text/javascript"></script>
	<!-- Mura Admin JS -->
	<script src="#application.configBean.getContext()#/admin/assets/js/admin.min.js" type="text/javascript"></script>

	<script src="#application.configBean.getContext()#/admin/assets/js/json2.js" type="text/javascript"></script>
	<script type="text/javascript" src="#application.configBean.getContext()#/admin/assets/js/admin.js"></script>
	<link href="#application.configBean.getContext()#/admin/assets/css/admin.min.css" rel="stylesheet" type="text/css" />
	<link href="#application.configBean.getContext()#/admin/assets/css/dialog.min.css" rel="stylesheet" type="text/css" />	

	
	<script type="text/javascript">
		<cfif url.compactDisplay eq 'true'>
			var frontEndProxy;
				jQuery(document).ready(function(){

				if (top.location != self.location) {
					frontEndProxy = new Porthole.WindowProxy("#session.frontEndProxyLoc##application.configBean.getContext()#/admin/assets/js/porthole/proxy.html");
					frontEndProxy.post({cmd:
						'setHeight',
						height:Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight)
						});
					jQuery(this).resize(function(e){
						frontEndProxy.post({cmd:
							'setHeight',
							height:Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight)
						});
					});					
				};

				parent.scrollTo(0,0);
				frontEndProxy.post({cmd:'setWidth',width:1100});
			});	
		</cfif>

		$(function(){
			$('.btn').click(function(e){
				e.preventDefaul();
				actionModal($(this).attr('href'));
			});
		});
	</script>
 </head>
 <body>
<div align="center">
	<h2>Preview and <cfif requiresApproval>Send for Approval<cfelse>Approve</cfif></h2>
		<div class="btn-group">
			<a class="btn" href="#content.getEditURL(compactDisplay=url.compactDisplay)#">Keep Working</a>
			<a class="btn" href="preview.cfm?siteid=#content.getSiteID()#&contenthistid=#content.getContentHistID()#&approve=true&compactDisplay=#URLEncodedFormat(url.compactDisplay)#&changesetid=#URLEncodedFormat(url.changesetid)#">
				#actionLabel#
			</a>
		</div>
		<br/>
		<br/>	
	<div id="" style="overflow:scroll; height:1200; width:100%; align:center">
		<iframe src="#content.getURL(complete=true,queryString='?muraadminpreview')#" width="100%" height="100%"/>
	</div>	
</div>	
</body>
</html>
</cfoutput>