# Computational evidence skipped

Finite computation is not an appropriate verifier for the theorem proved here. The principal claims are equalities and strict inequalities between transfinite ordinals, including that no ordinal below `ω ^ ω` is a sufficient forcing budget. Sampling finite branches can illustrate the construction but cannot establish these universal lower bounds and could be misleading.

Instead, `Core.lean` defines the game trees and their ordinal-valued semantics directly and proves all exact-value and lower-bound claims symbolically. In particular, `omegaOmegaGame_not_forcesWithin` quantifies over every ordinal `α < ω ^ ω`, rather than over a finite sample. The file is kernel-checked without `sorry` or added axioms.
