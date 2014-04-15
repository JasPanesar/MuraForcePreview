/*Copyright 2013 Blue River Interactive

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
*/
component extends="mura.plugin.pluginGenericEventHandler" {
	
	function onApplicationLoad($){
		variables.pluginConfig.addEventHandler(this);
	}

	function onBeforeContentSave($){


		if($.event('muraAction') == 'carch.update' 
			&& $.event('action') == 'add'
			&& listFindNoCase('Page,Folder,Gallery,Calender',$.content('type'))
			&& $.content('approved')
			&& !$.content('approvingChainRequest')
			&& !(isBoolean($.content('forcepreview')) && !$.content('forcepreview'))
		){	
			$.event('forcepreview',true);
			$.content('approved',0);
			$.event('approvalRequest','');
			$.event('changesetid',$.content('changesetid'));
			$.content('changesetid','');
		} else {
			$.event('forcepreview',false);
			if(isBoolean($.content('activeOverride')) && $.content('activeOverride')){
				$.content('active',1);
			}
		}

	}
	
	function onAfterContentSave($){
		if(!$.content().hasErrors() && $.event('forcepreview'))
		{	
			location(url="../plugins/MuraForcePreview/preview.cfm?contenthistid=#$.content('contenthistid')#&siteid=#URLEncodedFormat($.content('siteid'))#&compactDisplay=#URLEncodedFormat($.event('compactDisplay'))#&changesetid=#URLEncodedFormat($.event('changesetid'))#", addToken=false);
	
		}

	}
}
