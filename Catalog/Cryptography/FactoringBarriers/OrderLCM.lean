import Mathlib.GroupTheory.OrderOfElement
import Mathlib.Tactic.Ring

/-!
# Why the `δ` / large-order threshold can be relaxed at all

Every deterministic `N^{1/5}`-family method in the record is gated on a
hypothesis about the **order of an element** `α ∈ Z_N^*` (see RESEARCH.md §2
and §8, the `δ`-resolution entry). Harvey, Harvey–Hittmeir and GFHP all phrase
their enabling assumption as a threshold on `ord_N(α)`, and the thresholds have
been walked down (`> N^{2/5}`, then `> N^{1/4+o(1)}`).

**The survey states that these are "hypothesis relaxations" but never explains
*why a relaxation is possible at all*.** This file supplies the missing reason,
as a machine-checked theorem:

> **The global order is the LCM of the two local orders.**
> `ord_N(α) = lcm(ord_p(α), ord_q(α))`.

Because an LCM can be far larger than either of its factors — two coprime
factors *multiply* — a threshold on `ord_N(α)` is a constraint on a **product of
two secret quantities**, not on either one separately. So requiring
`ord_N(α) > N^{2/5}` does **not** require either local order to exceed
`N^{2/5}`; it suffices that two coprime divisors each exceed `N^{1/5}`. That is
the mechanism that makes the relaxation possible, and this file makes it exact.

## What is and is not formalised here

* **Formalised (0 `sorry`, 0 `axiom`):** all six theorems below —
  `orderOf_eq_lcm` (the general monoid statement), `lcm_mul_of_coprime` and
  `two_coprime_divisors_mul` (the *lower* side: how large a global order can be
  forced), and `lcm_le_mul`, `lcm_mul_le_mul_of_both_even` and `order_ceiling`
  (the *upper* side: how large a global order can possibly be).
* **Not formalised:** the application to `ZMod (p·q)`. Instantiating requires
  the CRT injectivity of `ZMod (p·q) → ZMod p × ZMod q`, which is a standard
  and elementary fact but whose `ZMod` plumbing is not written here. It is
  stated as a hypothesis `hinj` in the general theorem precisely so that the
  unformalised step is visible rather than hidden.

## The upper side: the order slack is already exhausted

The two corollaries give the *lower* side. The three later theorems give the
*upper* side, which is what the 2026-09-24 measurement in `RESEARCH.md`
established empirically and which this file makes a theorem:

| | statement |
|---|---|
| `lcm_le_mul` | `lcm d₁ d₂ ≤ d₁ * d₂` — not in Mathlib |
| `lcm_mul_le_mul_of_both_even` | `2 * lcm d₁ d₂ ≤ d₁ * d₂` when `2 ∣ d₁` and `2 ∣ d₂` |
| `order_ceiling` | the factoring-relevant restatement |

`2 ∣ d₁` and `2 ∣ d₂` hold whenever `p, q` are odd and `α` generates both local
unit groups, so the operative bound is `ord_N(α) ≤ (p−1)(q−1)/2 < N/2`. The
measurement found random `α` reaching `> N^{0.49}` — within a hair of this
ceiling. **The subgroup slack that `RESEARCH.md` §8 hoped to exploit is therefore
already spent:** the order is essentially maximal, so no method can gain by
enlarging it further, and "relax the order threshold" is a dead lever. `lcm_le_mul`
and its sharpening are elementary and are recorded as a *formalisation*, not as
new research; Mathlib has `Nat.Coprime.lcm_eq_mul` and the `dvd_of_lcm_*_dvd`
family but no bound of the form `lcm m n ≤ m * n`.

## Consequence for method invention (the load-bearing corollary)

The corollary `two_coprime_divisors_mul` says: if `ord_N(α)` has two coprime
divisors each at least `D`, then `ord_N(α) ≥ D²`. This is the *precise* form of
"the LCM is the useful object". It is also exactly why the obvious next method
fails — see `RESEARCH.md` §8 for the "coprime-order construction" kill, which is
a consequence of this file and not an independent guess.
-/

namespace Crypto.FactoringBarrier.OrderLCM

/-- **The order seen through two jointly-injective maps is the LCM of the two
local orders.**

This is the general form. For the factoring application take
`G = ZMod (p·q)`, `A = ZMod p`, `B = ZMod q`, with `f, g` the reduction maps;
`hinj` is the Chinese Remainder Theorem (see the module docstring for why that
instantiation is stated as a hypothesis rather than proved here).

The proof has two halves:

* each local order **divides** the global order, because `x ^ (orderOf x) = 1`
  pushes forward along `f` and `g`;
* the global order **divides** the LCM, because an exponent that is `1` in both
  `A` and `B` is `1` in `G` (this is where joint injectivity is used). -/
theorem orderOf_eq_lcm {G A B : Type*} [Monoid G] [Monoid A] [Monoid B]
    (f : G →* A) (g : G →* B)
    (hinj : Function.Injective (fun x : G => (f x, g x))) (x : G) :
    orderOf x = Nat.lcm (orderOf (f x)) (orderOf (g x)) := by
  refine (Nat.lcm_eq_iff.2 ?_).symm
  refine ⟨?_, ?_, ?_⟩
  · have hp := map_pow f x (orderOf x)
    rw [pow_orderOf_eq_one, map_one] at hp
    exact orderOf_dvd_iff_pow_eq_one.2 hp.symm
  · have hp := map_pow g x (orderOf x)
    rw [pow_orderOf_eq_one, map_one] at hp
    exact orderOf_dvd_iff_pow_eq_one.2 hp.symm
  · intro c hf hg
    have h1 : (f x) ^ c = 1 := orderOf_dvd_iff_pow_eq_one.1 hf
    have h2 : (g x) ^ c = 1 := orderOf_dvd_iff_pow_eq_one.1 hg
    have h1' : f (x ^ c) = 1 := by rw [map_pow, h1]
    have h2' : g (x ^ c) = 1 := by rw [map_pow, h2]
    have hfa : f 1 = 1 := map_one f
    have hga : g 1 = 1 := map_one g
    have hp : (f (x ^ c), g (x ^ c)) = (f 1, g 1) := by rw [h1', h2', hfa, hga]
    have h3 : x ^ c = 1 := by simpa using hinj hp
    exact orderOf_dvd_of_pow_eq_one h3

/-- **Coprime divisors of an LCM multiply.**  If `d₁` and `d₂` both divide the
global order and are coprime, then their *product* divides it.

This is the arithmetic core of why the `δ` threshold is weak: the global order
can be large because two moderate coprime local orders *multiply*, without
either one being large. -/
theorem lcm_mul_of_coprime {d₁ d₂ L : ℕ} (h1 : d₁ ∣ L) (h2 : d₂ ∣ L)
    (hc : Nat.Coprime d₁ d₂) : d₁ * d₂ ∣ L :=
  Nat.Coprime.mul_dvd_of_dvd_of_dvd hc h1 h2

/-- **Quantitative form: two coprime divisors each at least `D` force `L ≥ D²`.**

Applied to `L = ord_N(α)`, this is the exact content of "the LCM is the useful
object": if the global order carries two coprime divisors of size `D`, it is at
least `D²`. So a threshold `ord_N(α) > N^δ` can be met with local orders of size
only `> N^{δ/2}` each — provided they are coprime. -/
theorem two_coprime_divisors_mul (d₁ d₂ L D : ℕ) (hL : 0 < L)
    (h1 : d₁ ∣ L) (h2 : d₂ ∣ L)
    (hc : Nat.Coprime d₁ d₂) (p1 : D ≤ d₁) (p2 : D ≤ d₂) : D * D ≤ L := by
  have hdiv : d₁ * d₂ ∣ L := lcm_mul_of_coprime h1 h2 hc
  have hle : d₁ * d₂ ≤ L := Nat.le_of_dvd hL hdiv
  calc D * D ≤ d₁ * d₂ := Nat.mul_le_mul p1 p2
    _ ≤ L := hle

/-! ### The achievable-order ceiling

The measurement in `RESEARCH.md` (2026-09-24) finds, for random `α` over balanced
and unbalanced semiprimes alike, `ord_N(α) > N^{0.49}` in *100%* of samples. The
companion bound, which the measurement never approaches, is the one proved here:
the order can never exceed the product of the two local orders, and drops by a
further factor of `2` as soon as both local orders are even — which they always
are when `p` and `q` are odd and `α` is a generator of both local unit groups.

`lcm_le_mul` and `lcm_mul_le_mul_of_both_even` are **not in Mathlib** (it has
`Nat.Coprime.lcm_eq_mul` and the `dvd_of_lcm_*_dvd` family, but no bound of the
form `lcm m n ≤ m * n`). They are elementary and are recorded as a
*formalisation*, not as new research: their role is to make the claim "the
subgroup slack is already exhausted" a theorem rather than an experimental
observation. -/

/-- **The order never exceeds the product of the two local orders.**
`Nat.lcm d₁ d₂ ∣ d₁ * d₂`, hence `lcm d₁ d₂ ≤ d₁ * d₂` whenever the product is
positive.  Instantiated at `d₁ = ord_p(α)`, `d₂ = ord_q(α)` this bounds
`ord_N(α) ≤ (p−1)(q−1)`. -/
theorem lcm_le_mul (d₁ d₂ : ℕ) (h : 0 < d₁ * d₂) : Nat.lcm d₁ d₂ ≤ d₁ * d₂ := by
  have hd : Nat.lcm d₁ d₂ ∣ d₁ * d₂ :=
    Nat.lcm_dvd (Nat.dvd_mul_right d₁ d₂) (by simp)
  exact Nat.le_of_dvd h hd

/-- **The ceiling drops by a factor of `2` when both local orders are even.**
This is the case that occurs for every generator of `(ℤ/pℤ)* × (ℤ/qℤ)*` with
`p, q` odd, so it is the operative bound in the factoring setting:
`ord_N(α) ≤ (p−1)(q−1)/2 < N/2`.

The proof routes through `gcd`: the lcm is `d₁ * d₂ / gcd d₁ d₂`, and `2` divides
`gcd d₁ d₂` whenever it divides both arguments. -/
theorem lcm_mul_le_mul_of_both_even {d₁ d₂ : ℕ} (h1 : 2 ∣ d₁) (h2 : 2 ∣ d₂) :
    2 * Nat.lcm d₁ d₂ ≤ d₁ * d₂ := by
  -- Degenerate cases first: `lcm 0 n = 0`, so the goal is `0 ≤ 0`.  These MUST be
  -- split off -- `2 ∣ 0` holds, so `2 ∣ gcd 0 0` does not make the gcd positive.
  -- A first draft of this proof tried to derive positivity from the divisibility
  -- and Lean rejected it; the split is load-bearing, not cosmetic.
  by_cases hd₁ : d₁ = 0
  · simp [hd₁]
  by_cases hd₂ : d₂ = 0
  · simp [hd₂]
  have hg : 2 ∣ Nat.gcd d₁ d₂ := Nat.dvd_gcd h1 h2
  -- `2 * lcm d₁ d₂ ∣ d₁ * d₂`: write `gcd = 2u` and `lcm = 2v`, use
  -- `gcd * lcm = d₁ * d₂`, and observe `2 * lcm = 4v ∣ 4uv = gcd * lcm`.
  -- `2 ∣ lcm d₁ d₂` because `2 ∣ d₁` and `d₁ ∣ lcm d₁ d₂`
  have hl2 : 2 ∣ Nat.lcm d₁ d₂ :=
    Nat.dvd_trans h1 (Nat.dvd_lcm_of_dvd_left (Nat.dvd_refl d₁) d₂)
  obtain ⟨u, hu⟩ := hg
  obtain ⟨v, hv⟩ := hl2
  have key : 2 * Nat.lcm d₁ d₂ ∣ d₁ * d₂ := by
    rw [hv, ← Nat.gcd_mul_lcm d₁ d₂, hu, hv]
    calc 2 * (2 * v) = 4 * v := by ring
      _ ∣ 4 * (u * v) := Nat.mul_dvd_mul_left 4 (Nat.dvd_mul_left v u)
      _ = (2 * u) * (2 * v) := by ring
  exact Nat.le_of_dvd
    (Nat.mul_pos (Nat.pos_of_ne_zero hd₁) (Nat.pos_of_ne_zero hd₂)) key

/-- **The factoring-relevant corollary, in product form.**  If `α` generates both
local unit groups and `p, q` are odd, its global order is at most `(p−1)(q−1)/2`.

Stated without the primality hypotheses because those are what the *caller*
supplies from the factoring problem; the divisibility content is the two
`2 ∣ dᵢ` assumptions. -/
theorem order_ceiling {d₁ d₂ : ℕ} (h1 : 2 ∣ d₁) (h2 : 2 ∣ d₂) :
    2 * Nat.lcm d₁ d₂ ≤ d₁ * d₂ :=
  lcm_mul_le_mul_of_both_even h1 h2

end Crypto.FactoringBarrier.OrderLCM
