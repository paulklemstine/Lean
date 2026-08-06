# Why the computational-evidence stage is skipped

The results in `Catalog/Physics/ZeroPointHarvestingLossy.lean` are exact symbolic
consequences of an assumed per-cycle energy balance law

    stored (t+1) + harvested t + dissipated t = stored t + injected t

together with nonnegativity of the four sequences. Every theorem is obtained by
telescoping this identity over a finite horizon and applying elementary
inequalities. There is no combinatorial or numerical conjecture involved: the
statements are universally quantified over *all* sequences satisfying the balance
law, so evaluating particular numerical trajectories would only re-instantiate
the hypotheses and could never provide evidence beyond the Lean proof itself.

One place where a "search" could conceivably have been useful is the tightness
question — whether the bound `netExport N ≤ stored 0` is attained. That question
is not resolved numerically here either: it is settled *constructively and
formally* by `exists_tight_process`, which exhibits an explicit process
(dump the entire reserve `E` in the first cycle, then idle) whose net export
equals `stored 0` on every nonempty horizon, and by `netExport_eq_initial_iff`,
which characterises equality as "final storage zero and no dissipation". A
machine-checked construction is strictly stronger than tabulated examples.
