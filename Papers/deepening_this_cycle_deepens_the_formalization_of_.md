# Computational Evidence — Grounded extension is the least complete extension

The new file `ArgumentationGrounded.lean` proves that the **grounded extension**
`groundedExt R = OrderHom.lfp (charF R)` of a Dung argumentation framework
`(A, R)` is conflict-free, admissible, complete, and is the least complete
extension. The delicate claim is **conflict-freeness of the least fixed point**;
below is finite-case evidence that this holds (and that fixed points that are not
the *least* fixed point can fail to be conflict-free, so leastness is essential).

## Small cases

Notation: `charF S = {a | every attacker of a is counter-attacked by S}`.

### 1. Empty relation on `{0,1}` (no attacks)
- `charF ∅ = {0,1}` (everything is unattacked), and `charF {0,1} = {0,1}`.
- Iteration from `∅`: `∅ → {0,1} → {0,1}` (fixed). Grounded `= {0,1}`.
- `{0,1}` is conflict-free (no attacks at all). ✓ Consistent with the theorem.

### 2. Two-cycle `0 ↔ 1` (`R 0 1`, `R 1 0`)
- `charF ∅ = ∅` (0 is attacked by 1, nobody in ∅ counter-attacks; same for 1).
- Iteration from `∅`: `∅ → ∅` (fixed). Grounded `= ∅`.
- `∅` is conflict-free. ✓
- Note: `{0}` and `{1}` are the (preferred/stable) extensions; grounded is the
  skeptical `∅ ⊆ {0}, {1}`. Consistent with `groundedExt_subset_complete`.

### 3. Self-attack `R 0 0` on `{0}`
- `charF ∅ = ∅`, grounded `= ∅`, conflict-free. ✓
- Here `{0}` is **not** conflict-free; note `charF {0} = ∅ ⊆ {0}` but `{0}` is not
  a fixed point, so not complete — matches `complete_iff_conflictFree_fixed`.

### 4. A non-least fixed point that is NOT conflict-free
- Framework on `{0,1}` with `R 0 1` and `R 1 0` and additionally `R 0 0`.
  Take `S = {0,1}`. Then `charF {0,1}`: is `0` defended? attackers of 0 are
  `{1,0}`; `1` is attacked by `0 ∈ S`, and `0` is attacked by `1 ∈ S`, so `0` is
  defended; symmetrically `1` is defended, so `charF {0,1} = {0,1}` — a fixed
  point. But `{0,1}` is **not conflict-free** (`R 0 1`).
- Yet the grounded (least) fixed point is `∅` here, which *is* conflict-free.
- This confirms that conflict-freeness is a property of the **least** fixed
  point, not of arbitrary fixed points — exactly why the Lean proof uses the
  transfinite `lfpApprox` chain rather than the fixed-point equation alone.

## Directed/chain-union check
The proof reduces conflict-freeness of the grounded extension to:
"a chain (directed family) of conflict-free sets has a conflict-free union."
Finite check: chain `∅ ⊆ {0} ⊆ {0,1}` of conflict-free sets in the empty-relation
framework — union `{0,1}` is conflict-free. ✓ (Arbitrary, non-chain unions of
conflict-free sets can fail, e.g. `{0} ∪ {1}` in the two-cycle, which is why the
`conflictFree_of_directed` hypothesis is required.)

## Conclusion
All finite samples are consistent with the theorem, and case 4 exhibits the
necessity of leastness. This matches the formal proof strategy.
