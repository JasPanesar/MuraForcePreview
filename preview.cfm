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

<cfsavecontent variable="body">
	<cfoutput>
		<h2>Preview and <cfif requiresApproval>Send for Approval<cfelse>Approve</cfif></h2>
		<cfif url.compactDisplay eq 'true'>
		<script type="text/javascript">
			$(function(){
				parent.scrollTo(0,0);
				frontEndProxy.post({cmd:'setWidth',width:1100});
			});
		</script>
		</cfif>
		<div class="btn-group">
			<a class="btn active" href="#content.getEditURL(compactDisplay=url.compactDisplay)#">Keep Working</a>
			<a class="btn active" href="preview.cfm?siteid=#content.getSiteID()#&contenthistid=#content.getContentHistID()#&approve=true&compactDisplay=#URLEncodedFormat(url.compactDisplay)#&changesetid=#URLEncodedFormat(url.changesetid)#">
				#actionLabel#
			</a>
		</div>
		<iframe src="#content.getURL(complete=true,queryString='?muraadminpreview')#" width="100%" height="600"/>
			
		<!---
		<cfelse>	
			<script type="text/javascript">
				$(function(){
					openPreviewDialog(
						"#content.getURL(complete=true)#",
						{
							"#actionLabel#":function(){
												actionModal(function(){location.href="preview.cfm?siteid=#content.getSiteID()#&contenthistid=#content.getContentHistID()#&approve=true&compactDisplay=#URLEncodedFormat(url.compactDisplay)#&changesetid=#URLEncodedFormat(url.changesetid)#"});
											},
							"Keep Working":function(){
												actionModal(function(){location.href="#content.getEditURL()#"});
											}
						},
						function(){
									actionModal(function(){location.href="#content.getEditURL()#"});
						}
					);
				});
			</script>
		</cfif>
		--->
	</cfoutput>
</cfsavecontent>

<cfoutput>
	#$.getBean('pluginManager').renderAdminTemplate(body=body,compactDisplay=url.compactDisplay)#
</cfoutput>
