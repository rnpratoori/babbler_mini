//* This file is part of the MOOSE framework
//* https://www.mooseframework.org
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "trialTestApp.h"
#include "trialApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
trialTestApp::validParams()
{
  InputParameters params = trialApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  return params;
}

trialTestApp::trialTestApp(InputParameters parameters) : MooseApp(parameters)
{
  trialTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

trialTestApp::~trialTestApp() {}

void
trialTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  trialApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"trialTestApp"});
    Registry::registerActionsTo(af, {"trialTestApp"});
  }
}

void
trialTestApp::registerApps()
{
  registerApp(trialApp);
  registerApp(trialTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
trialTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  trialTestApp::registerAll(f, af, s);
}
extern "C" void
trialTestApp__registerApps()
{
  trialTestApp::registerApps();
}
