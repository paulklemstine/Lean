Produce a complete Lean 4 file that formalizes a self-contained arithmetic stability theory for `padicValNat p` on natural numbers, designed as the prerequisite layer for a later tropical/ultrametric bridge. Do not lead with categorical abstractions; instead, prove precise theorems with complete bodies and no placeholders.

Working title: `Catalog/Computation/PadicValuationDepthStability.lean`.

Primary goal: for a prime natural `p`, define or reuse a valuation-depth notation based on `padicValNat p`, then prove a robust theorem suite about multiplication, powers, sums, perturbations, and finite lists. Favor statements that match existing Mathlib facts closely enough to be provable without heroic library extensions.

Required content:
1. State assumptions explicitly, typically `[Fact p.Prime]` or `hp : p.Prime`.
2. Reuse existing `padicValNat` lemmas whenever possible instead of reproving deep facts from scratch.
3. Prove concrete arithmetic theorems, with exact names chosen to fit the file, along the following lines:
   - multiplicativity: for nonzero naturals, `padicValNat p (m * n) = padicValNat p m + padicValNat p n`;
   - powers: `padicValNat p (m^k) = k * padicValNat p m` or an equivalent additive formula already supported by Mathlib;
   - prime powers: evaluate `padicValNat p (p^k)` exactly;
   - divisibility criterion: connect `k ≤ padicValNat p n` with `p^k ∣ n` in the direction(s) already available in the library;
   - ultrametric lower bound for addition: derive a theorem saying the valuation of `m+n` is at least the minimum of the valuations of `m` and `n`, with hypotheses arranged to avoid issues at zero if needed;
   - sharp isosceles law: if `padicValNat p m < padicValNat p n`, then `padicValNat p (m+n) = padicValNat p m`;
   - perturbation stability: if the perturbation has strictly larger valuation depth, then adding it does not change the depth;
   - list product formula: valuation of a finite product is the sum of valuations;
   - list sum lower bound: if every term in a list has valuation at least `k`, then the total sum has valuation at least `k`.
4. Use finite-list theorems with `List.prod` and `List.sum`, proved by induction.
5. Be careful about zero: if exact equalities fail or become awkward at zero, either add nonzero hypotheses or formulate inequalities that remain true. Prefer mathematically honest statements over overgeneralized ones.
6. Include short module documentation explaining that this file is the arithmetic substrate for a later tropical/ultrametric bridge, but do not attempt the full bridge theorem here unless it is a very light corollary.

Important methodological guidance:
- The previous attempt was partial because it appears to have theorem declarations without complete bodies. This retry must prioritize completeness and checkability.
- Do not invent unsupported theorem names from Mathlib. Search for existing lemmas on `padicValNat`, divisibility by prime powers, and valuation of products/powers, and wrap them carefully.
- If an intended exact theorem is too difficult in the available library, weaken it slightly to a one-sided inequality or add the necessary hypotheses, but finish the proof.
- Prefer a finished, strong arithmetic file over an ambitious but incomplete bridge file.

Deliverable:
- A single complete Lean file with all imports, theorem statements, and proofs.
- No `sorry`, no placeholders, no incomplete tactic fragments.
- The file should compile independently within the catalog and be suitable for later use by a bridge theorem in a separate file.