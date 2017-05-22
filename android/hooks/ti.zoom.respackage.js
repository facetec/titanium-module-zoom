
// This hook shouldn't be necessary, but Titanium CLI doesn't respect the 'respackageinfo' field in the manifest.
// https://jira.appcelerator.org/browse/AC-4980
// This can be removed if bug is fixed
exports.init = function(logger, config, cli, appc) {
  cli.on('build.android.titaniumprep', {
    pre : function(data) {
      var fs = require('fs');
    
      var moduleId = "com.facetec.ti.zoom";
      var module = data.ctx.modules.find(function(m) { return m.id == moduleId; });

      if (!module) {
        throw "Module " + exports.moduleId + " not found.";
      }

      var modulePath = module.modulePath;
      fs.writeFileSync(modulePath + "/" + "respackageinfo", "com.facetec.zoom.sdk", {
        encoding : 'utf-8',
        flag : 'w'
      });
    }
  });
};
