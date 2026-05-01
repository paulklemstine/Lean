/-! # CatalogBuild.Speculative.SciFi.TropicalFirewall

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 1
-/

import Mathlib

/-- Tropical Firewall Determinism.
A starship crosses the event horizon of a wormhole and encounters the infamous 'firewall'—a wall of high-energy radiation that destroys information. The crew theorizes that the firewall is a tropical variety: spacetime intervals are measured in max-plus algebra, where taking the 'sum' of two paths means keeping only the dominant causal delay. The theorem shows that if the firewall singularity a is not the dominant path (a < max(a,b)), then any two possible escape trajectories b and c that produce the same tropical boundary condition must be identical. Inside the firewall, determinism is restored by the absence of additive inverses.
Mathematical Concept: Tropical (max-plus) semiring cancellation applied to causal structure. In a tropical encoding of spacetime events, information is additive under max. The theorem proves a local cancellation law: if two distinct causal histories yield the same tropical supremum and the background event is strictly subdominant, the histories must coincide. This models the black-hole firewall as a tropical hypersurface where alternative histories collapse to a single outcome.
Proof Strategy: Use the definition of max in a linear order. Since a < max(a,b), we have max(a,b) = b. Similarly max(a,c) = c. Equality of the maxima yields b = c directly. This is a one-line proof via `cases` and `linarith`, but the conceptual framing elevates it to a statement about irreversibility in semirings without cancellation.
Difficulty: graduate
Arc: Tropical Langlands -/
theorem tropical_firewall_determinism
    {R : Type*} [LinearOrder R]
    (a b c : R) (h : max a b = max a c) (hgt : a < max a b) :
    b = c := by
  cases max_cases a b <;> cases max_cases a c <;> aesop

