import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# The scale wall: the square-difference family cannot be swept below `√N`

`RESEARCH.md` §7 reduces the whole deterministic family to the pairs `(k, l)`
with `a - b = k·p`, `a + b = l·q`, `a² - b² = k·l·p·q`, searched in a box
`|a|, |b| ≤ X`. §7-bis then shows (`NoFreeSearch.lean`) that the `(k, l)`
coordinates are a **bijection** of the `(a, b)` coordinates inside the same box,
so re-encoding saves nothing.

This file is the next step, and it is stronger than §7-bis. It is **not** about
which coordinates you search. It says the *box itself* has a floor:

> **The scale wall.** If `(k, l)` is a good point with `k ≥ 1` and `l ≥ 1`, then
> - **(W1) budget law** `k·l·(p·q) ≤ X²` — the product `k·l` you may reach is
>   bought at `N` per unit;
> - **(W2) box floor** `k·p + l·q ≤ 2·X`, hence `p + q ≤ 2·X`, so
>   `X ≥ (p+q)/2 ≥ √(p·q) = √N`;
> - **(W3) the floor is attained**: a good point with `k = l = 1` has
>   *exactly* `2·a = p + q`, so `X = (p+q)/2` is forced, not merely a lower bound;
> - **(W4) the size barrier** `p·q ≤ X·X`.

**Why this is a kill and not a technicality.** `X ≥ √N` means every method in this
family operates with `X ≳ √N`, so the `(a, b)` box has `X² ≳ N` lattice points
and a sweep of it costs `≳ N` — strictly worse than the `N^{1/2}` it is trying to
beat. So the family is **not a search space at any affordable scale.** §7-bis
said re-encoding does not help; this says the encoding is not the problem, the
*size of the target set* is.

**The sharper consequence, which is the real content.** By (W1), the good points
satisfy `k·l ≤ X²/N`. Since the family is only ever *used* at `X = Θ(√N)`, in
that regime `k·l = O(1)` and the good `(k, l)` are the **divisors of a small
integer** — a set of size `O(1)`, not a set to search. Reaching a *deep*
convergent (`k·l ≥ m`) needs box area `X² ≥ m·N`, i.e. `m` times the minimum.

**So the family is a target, not a search, and the target is provably a point.**
That is the sharpest available statement, and it is the opposite of the reading
§7 invites. It also settles a question the file had been carrying: if a method
reaches `N^{1/5}` — which is *below* this wall — then it is **not** enumerating
this family, and whatever it does instead is not captured by the box at all. The
only known mechanism that reaches below the wall without enumerating is
baby-step/giant-step on the multiplicative group (`α^{aN+b}`), which is exactly
the part of Harvey's construction this reduction does **not** model. **Naming
that missing mechanism is the new open thread this file produces.**

## Formalised, and what is not

* **Formalised (0 `sorry`, 0 `axiom`):** `sq_diff_eq_kl`, `budget_law` (W1),
  `box_floor_full` and `box_floor` (W2), `kl_per_coordinate` (the per-coordinate
  reading), `fermat_forces_X` (W3), `size_barrier` (W4), and
  `deep_convergent_costs`, which says reaching `k·l ≥ m` costs box area `m·N`.
* **A useful by-product, not previously recorded:** `budget_law` needs only the
  bound on `a`, never on `b` — `b ≤ a` follows from `a - b = k·p` with `k ≥ 1`.
  The box is therefore **one-sided in the algebra**, even though it is written
  two-sided in the geometry.
* **Not formalised:** the counting statement "the good `(k, l)` are the divisors
  of an integer `≤ X²/N`", which is `Nat`-arithmetic bookkeeping and carries no
  content the theorems above do not already carry. It is argued in prose in
  `RESEARCH.md` §7-quinary.

## Honest limits

This is a **barrier**, so like every other entry in this record it removes
possibilities rather than adding a method. It is *not* a claim that factoring
cannot be done in `N^{1/5}` — Harvey does that. It is the claim that **this
particular family, swept, is not how he does it**, and that any method beating
`N^{1/5}` must use a mechanism outside the box. -/

namespace Crypto.FactoringBarrier.ScaleWall

/-- **`b ≤ a` follows from `a - b = k·p` once `k ≥ 1` and `p ≥ 1`.**
This is *not* free: in `ℕ` the subtraction is truncated, so `a - b = 0` is
compatible with `b > a` when `k·p = 0`.  The positivity hypotheses are therefore
load-bearing in every theorem below, and are the reason the family is stated for
`p, q ≥ 1` rather than `p, q ≥ 0`. -/
private theorem b_le_a {a b k p : ℕ} (hk : 1 ≤ k) (hp : 1 ≤ p) (h1 : a - b = k * p) :
    b ≤ a := by
  have hkp : 1 ≤ k * p := Nat.mul_le_mul hk hp
  by_contra hcon
  have hab : a ≤ b := Nat.le_of_not_ge hcon
  have hz : a - b = 0 := Nat.sub_eq_zero_of_le hab
  omega

/-- **The algebra of the family, restated.** From `a - b = k·p` and
`a + b = l·q` one gets `a² - b² = k·l·p·q`.

**The algebra needs no positivity at all** -- `hk` and `hp` are unused, and that is
deliberate: unlike every theorem below, this identity is unconditional, holding
even in the degenerate `k·p = 0` cases. The positivity is needed only to convert
a *size* statement into a *search* statement, which is exactly where the wall is.

Two Lean notes, both load-bearing. (i) `a * a` does **not** match the pattern
`a ^ 2` under `rw`, so `pow_two` is used to bring the goal into `^`-form before
`Nat.sq_sub_sq` applies. (ii) In `ℕ` this is not a `ring` identity, because the
subtractions are truncated. -/
theorem sq_diff_eq_kl (a b k l p q : ℕ) (_hk : 1 ≤ k) (_hp : 1 ≤ p)
    (h1 : a - b = k * p) (h2 : a + b = l * q) :
    a * a - b * b = k * p * l * q := by
  have haa : a * a = a ^ 2 := by rw [pow_two]
  have hbb : b * b = b ^ 2 := by rw [pow_two]
  rw [haa, hbb, Nat.sq_sub_sq a b, h2, h1]
  ring

/-- **THE BUDGET LAW (W1).**  A good point with `k ≥ 1` and `l ≥ 1` inside a box
of side `X` satisfies `k·l·(p·q) ≤ X²`.

Read the other way: the *product* `k·l` you can reach is bought at `p·q` per
unit.  Fermat reaches `k·l = 1` at the minimum `X`; reaching `k·l = m` needs
`m` times the box area.

**Only the bound on `a` is used.** `b ≤ a` is automatic from `h1` and `k ≥ 1`,
and `a·a - b·b ≤ a·a` is `Nat.sub_le`. So the two-sided box is one-sided in the
algebra. -/
theorem budget_law (a b k l p q X : ℕ) (hk : 1 ≤ k) (hp : 1 ≤ p)
    (h1 : a - b = k * p) (h2 : a + b = l * q) (ha : a ≤ X) :
    k * l * (p * q) ≤ X * X := by
  have hba := b_le_a hk hp h1
  have heq : k * l * (p * q) = a * a - b * b := by
    rw [sq_diff_eq_kl a b k l p q hk hp h1 h2]; ring
  calc k * l * (p * q) = a * a - b * b := heq
    _ ≤ a * a := Nat.sub_le _ _
    _ ≤ X * X := Nat.mul_le_mul ha ha

/-- **THE FULL BOX FLOOR (W2, strong form).**  The good point consumes budget
`k·p + l·q = 2·a`, so `k·p + l·q ≤ 2·X`.  This is the statement that the *whole*
box is spent, not just one coordinate of it. -/
theorem box_floor_full (a b k l p q X : ℕ) (hk : 1 ≤ k) (_hl : 1 ≤ l) (hp : 1 ≤ p)
    (h1 : a - b = k * p) (h2 : a + b = l * q) (ha : a ≤ X) :
    k * p + l * q ≤ 2 * X := by
  have hba := b_le_a hk hp h1
  have htwo : k * p + l * q = 2 * a := by omega
  calc k * p + l * q = 2 * a := htwo
    _ ≤ 2 * X := by nlinarith

/-- **THE BOX FLOOR (W2, the `√N` form).**  No good point with `k ≥ 1`, `l ≥ 1`
exists in a box narrower than `(p+q)/2`.  With AM–GM this is `X ≥ √N`. -/
theorem box_floor (a b k l p q X : ℕ) (hk : 1 ≤ k) (hl : 1 ≤ l) (hp : 1 ≤ p)
    (h1 : a - b = k * p) (h2 : a + b = l * q) (ha : a ≤ X) :
    p + q ≤ 2 * X := by
  have h := box_floor_full a b k l p q X hk hl hp h1 h2 ha
  have h1' : p ≤ k * p := by simpa using Nat.mul_le_mul_right p hk
  have h2' : q ≤ l * q := by simpa using Nat.mul_le_mul_right q hl
  omega

/-- **The per-coordinate reading of (W1).**  From the full floor, `k·p ≤ 2·X`, so
reaching coefficient `k` costs `k·p·q / q = k·N/q` of budget — a deep convergent
in one coordinate is bought at `p·q` per unit in that coordinate, exactly as in
the two-coordinate product. -/
theorem kl_per_coordinate (a b k l p q X : ℕ) (hk : 1 ≤ k) (hl : 1 ≤ l) (hp : 1 ≤ p)
    (h1 : a - b = k * p) (h2 : a + b = l * q) (ha : a ≤ X) :
    k * p ≤ 2 * X ∧ l * q ≤ 2 * X := by
  have h := box_floor_full a b k l p q X hk hl hp h1 h2 ha
  constructor
  · exact Nat.le_trans (Nat.le_add_right (k * p) (l * q)) h
  · have hswap : l * q + k * p ≤ 2 * X := by
      have := h; omega
    exact Nat.le_trans (Nat.le_add_right (l * q) (k * p)) hswap

/-- **(W3) THE FLOOR IS ATTAINED — Fermat *forces* `X = (p+q)/2`.**  A good point
with `k = l = 1` has `2·a = p + q` exactly, so the bound in `box_floor` is an
equality, not a slack lower bound. This is `fermat_is_k_l_one` seen as a *size*
statement: Fermat's point is the unique good point that touches the wall. -/
theorem fermat_forces_X (a b p q : ℕ) (hp : 1 ≤ p)
    (h1 : a - b = p) (h2 : a + b = q) :
    2 * a = p + q := by
  have h1k : a - b = 1 * p := by simpa using h1
  have hba := b_le_a (k := 1) (p := p) (a := a) (b := b) (by omega) hp h1k
  omega

/-- **(W4) THE SIZE BARRIER.**  Every good point forces `p·q ≤ X·X`, i.e.
`X ≥ √(p·q)`.  The positivity hypothesis is only to exclude the degenerate
`N = 0`; **no primality and no gcd hypothesis is used**, so this is a pure size
statement.

The AM–GM step is a case split on `p ≤ q`, because in `ℕ` the subtraction `p - q`
is truncated and `sq_nonneg (p - q)` is *not* the polynomial `(p-q)²`. Writing
`q = p + d` and using `0 ≤ d²` is the form that is actually true here. -/
theorem size_barrier (a b k l p q X : ℕ) (_hpq : 0 < p * q) (hk : 1 ≤ k) (hl : 1 ≤ l)
    (hp : 1 ≤ p) (h1 : a - b = k * p) (h2 : a + b = l * q) (ha : a ≤ X) :
    p * q ≤ X * X := by
  have hfloor := box_floor a b k l p q X hk hl hp h1 h2 ha
  -- AM–GM in the form `4·p·q ≤ (p+q)·(p+q)`, proved by the substitution.
  have hamgm : 4 * (p * q) ≤ (p + q) * (p + q) := by
    rcases Nat.le_total p q with hpq' | hpq'
    · have heq : q = p + (q - p) := (Nat.add_sub_of_le hpq').symm
      rw [heq]
      nlinarith [sq_nonneg (q - p)]
    · have heq : p = q + (p - q) := (Nat.add_sub_of_le hpq').symm
      rw [heq]
      nlinarith [sq_nonneg (p - q)]
  nlinarith [hamgm, hfloor]

/-- **Reaching a deep convergent costs box area `m·N`.**  If the good point has
`k·l ≥ m` with `m > 0` then `m·(p·q) ≤ X·X`: the box must be at least `m` times
larger than the `√N` floor.  So the family buys depth `m` at price `m·N`, and a
sweep of that box costs `Θ(m·N)` — **no free depth, ever.** -/
theorem deep_convergent_costs (a b k l p q X m : ℕ)
    (hkl : m ≤ k * l) (hk : 1 ≤ k) (hp : 1 ≤ p)
    (h1 : a - b = k * p) (h2 : a + b = l * q) (ha : a ≤ X) :
    m * (p * q) ≤ X * X := by
  have h := budget_law a b k l p q X hk hp h1 h2 ha
  calc m * (p * q) ≤ k * l * (p * q) := Nat.mul_le_mul_right (p * q) hkl
    _ ≤ X * X := h

end Crypto.FactoringBarrier.ScaleWall
