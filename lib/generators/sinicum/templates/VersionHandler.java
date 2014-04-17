package <%= version_handler_package %>;

import java.util.List;

import info.magnolia.module.DefaultModuleVersionHandler;
import info.magnolia.module.delta.ModuleBootstrapTask;
import info.magnolia.module.delta.Task;
import info.magnolia.module.model.Version;

public class VersionHandler extends DefaultModuleVersionHandler {

    @Override
    protected List<Task> getDefaultUpdateTasks(Version forVersion) {
        List<Task> tasks = super.getDefaultUpdateTasks(forVersion);
        tasks.add(new ModuleBootstrapTask());
        return tasks;
    }
}
