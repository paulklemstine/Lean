# Summary of changes for run af9835cb-ef50-4eac-be80-529327a0a1cb
Created a new self-contained research file `Bridges/BerggrenHeightCertificate.lean` that builds a bridge between the catalog's Berggren–Lorentz theory of primitive Pythagorean triples (`Algebra/BerggrenLorentz/Core.lean`), order-theoretic acyclicity, and the certificate idiom of `Cryptography/NoetherianCertification.lean`. It imports and extends the catalog `Core` file directly (`childA/B/C`, `IsPythag`, `pythag_hyp_ge_leg_*`) rather than reproving anything.

Mathematical core: the linear-size height H(a,b,c)=a+b+c is proved strictly monotone under all three Berggren generators on the positive Pythagorean branch (per-generator increments 4a−6b+6c, 4a+4b+6c, 4b−6a+6c, each positive because the hypotenuse dominates both legs). From this single inequality the file derives:
- `onBranch_applyMove` — the primitive positive branch is invariant under every generator (well-defined dynamics);
- `height_lt_applyMove` — the core strict-monotonicity certificate;
- `acyclic` — no on-branch triple is Berggren-reachable from itself (the child graph is acyclic), via `transGen_height`;
- `height_injective_on_chain` — height is injective along a lineage, so the minimal/maximal-height representative of a lineage is unique;
- a `BerggrenAncestryCert` structure with full soundness theorems (`target_onBranch`, `cert_reaches`, `cert_strict`, `cert_no_cycle`, `cert_unique_at_height`) giving a checkable ancestry certificate, plus a concrete worked example on the seed triple (3,4,5)→(21,20,29).

The file (22 theorem/structure declarations) compiles cleanly with zero `sorry`, no warnings, no added axioms or `native_decide`; the main theorems depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound` (verified via `#print axioms`).

Deliverables included as required: the `.lean` file with `-- !-- ... --!--` proof-sketch and Lab Notebook comment blocks (Hypothesis / Result / Insight / Failure analysis), and `Bridges/FUTURE_DIRECTIONS.md` containing a synthesis, results summary, and five bold, falsifiable research directions (geometric depth bounds, uniqueness of parents, an executable decidable checker, cryptographic ancestry-reversal hardness, and a Lorentz-intrinsic height), each with a "key insight" and a "Why now?" justification.