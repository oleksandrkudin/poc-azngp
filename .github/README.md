Requirements
* Only changed components must be built, deployed.
* Components that directly or indirectly depends on changed components must be also built, deployed.
* Changes to common things like build, deploy workflows, scripts, ... must trigger build, deploy for all components.

* Build, yes, based on changes, but deploy (integration) must be done for each commit to integration branch.
* If deploy based on changes, then at some point must be whole deploy process to detect drift.