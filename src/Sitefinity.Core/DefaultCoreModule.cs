using Autofac;
using Sitefinity.Core.Interfaces;
using Sitefinity.Core.Services;

namespace Sitefinity.Core;

public class DefaultCoreModule : Module
{
  protected override void Load(ContainerBuilder builder)
  {
    builder.RegisterType<ToDoItemSearchService>()
        .As<IToDoItemSearchService>().InstancePerLifetimeScope();
  }
}
