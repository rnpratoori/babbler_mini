#include "trialApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
trialApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  return params;
}

trialApp::trialApp(InputParameters parameters) : MooseApp(parameters)
{
  trialApp::registerAll(_factory, _action_factory, _syntax);
}

trialApp::~trialApp() {}

void 
trialApp::registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  ModulesApp::registerAllObjects<trialApp>(f, af, s);
  Registry::registerObjectsTo(f, {"trialApp"});
  Registry::registerActionsTo(af, {"trialApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
trialApp::registerApps()
{
  registerApp(trialApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
trialApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  trialApp::registerAll(f, af, s);
}
extern "C" void
trialApp__registerApps()
{
  trialApp::registerApps();
}
