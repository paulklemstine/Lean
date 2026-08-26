import Mathlib
import Novelty.CellularAutomataAlgebraicGeometry

/-!
# The fixed-point variety of an elementary cellular automaton

This file sets up the algebraic-geometry style framework in which the
"ECA complexity = dimension of the fixed-point variety" conjecture can be
*tested*, building directly on the Boolean local rules of
`Novelty.CellularAutomataAlgebraicGeometry`.

A cyclic configuration of size `n` is a function `ZMod n → ZMod 2`, i.e. a point
of the affine space `𝔸ⁿ_{𝔽₂}` (for `n = 0` this degenerates to the bi-infinite
configuration space `ℤ → ZMod 2`, which is why all statements below are stated
uniformly over `ZMod n`).  The *fixed-point variety* of Wolfram rule `rule` is

  `V(rule, n) = { s : ZMod n → ZMod 2 | step rule s = s }`,

the `𝔽₂`-points of the zero locus of the `n` cubic polynomials
`fᵣ(s_{i-1}, s_i, s_{i+1}) - s_i`.

## Main results

* `localRuleZ_ofBool` — the `ZMod 2`-valued local rule agrees with the Boolean
  local rule of the catalog file, so this is genuinely the same dynamics.
* `mem_fixedSet_iff` — pointwise description of the fixed-point variety.
* `fixedSet_rotate` — the variety is invariant under the shift, i.e. it is a
  cyclic subshift of finite type, not an arbitrary subset.
* `IsAdditive.fixedSubmodule` — for an *additive* rule the variety really is a
  linear subspace, so a dimension `HasFixedDim` is defined.
* `rule204_hasFixedDim`, `rule204_fixedSet_univ` — the identity rule (Wolfram
  class 1/2) attains the maximal dimension `n`.
* `rule0_hasFixedDim_zero` — the null rule has dimension `0`.
* `hasFixedDim_unique` — the dimension, when it exists, is well defined.
-/

namespace ECAFixedVariety

open CellularAutomataAlgebraicGeometry

/-- Cyclic configuration space of size `n`: a point of affine `n`-space over `𝔽₂`.
For `n = 0` this is the bi-infinite configuration space `ℤ → 𝔽₂`. -/
abbrev Cfg (n : ℕ) := ZMod n → ZMod 2

/-- The `𝔽₂`-valued local rule of Wolfram rule number `rule`. -/
def localRuleZ (rule : ℕ) (l c r : ZMod 2) : ZMod 2 :=
  if rule.testBit (4 * l.val + 2 * c.val + r.val) then 1 else 0

/-- Every element of `𝔽₂` is `0` or `1`. -/
lemma zmod2_eq_zero_or_one : ∀ x : ZMod 2, x = 0 ∨ x = 1 := by decide

/-- Boolean-to-`𝔽₂` encoding of a cell. -/
def ofBool (b : Bool) : ZMod 2 := cond b 1 0

@[simp] lemma ofBool_true : ofBool true = 1 := rfl
@[simp] lemma ofBool_false : ofBool false = 0 := rfl

lemma ofBool_injective : Function.Injective ofBool := by decide

/-- The `𝔽₂`-valued local rule computes the same function as the Boolean local
rule `CellularAutomataAlgebraicGeometry.localRule`. -/
lemma localRuleZ_ofBool (rule : ℕ) (l c r : Bool) :
    localRuleZ rule (ofBool l) (ofBool c) (ofBool r) =
      ofBool (localRule rule l c r) := by
  cases l <;> cases c <;> cases r <;>
    simp [localRuleZ, localRule, neighborhoodIndex, ofBool, ZMod.val_one, ZMod.val_zero]

/-- One synchronous update step of Wolfram rule `rule` on cyclic configurations. -/
def step (rule : ℕ) {n : ℕ} (s : Cfg n) : Cfg n :=
  fun i => localRuleZ rule (s (i - 1)) (s i) (s (i + 1))

/-- The fixed-point variety `V(f) = {s : f(s) = s}` of a Wolfram rule. -/
def fixedSet (rule n : ℕ) : Set (Cfg n) := {s | step rule s = s}

lemma mem_fixedSet_iff {rule n : ℕ} {s : Cfg n} :
    s ∈ fixedSet rule n ↔ ∀ i, localRuleZ rule (s (i - 1)) (s i) (s (i + 1)) = s i := by
  constructor
  · intro h i; exact congrFun h i
  · intro h; funext i; exact h i

/-- The fixed-point variety is invariant under the cyclic shift: it is a
(cyclic) subshift of finite type. -/
lemma fixedSet_rotate {rule n : ℕ} {s : Cfg n} (hs : s ∈ fixedSet rule n) (k : ZMod n) :
    (fun i => s (i + k)) ∈ fixedSet rule n := by
  rw [mem_fixedSet_iff] at hs ⊢
  intro i
  have := hs (i + k)
  simpa [sub_add_eq_add_sub, add_right_comm] using this

/-! ### Periodicity transfer on the ring

Many fixed-point loci are governed by a spatial period `p`; when `p` is
invertible modulo the ring size the configuration is forced to be constant.
These generic lemmas are used for `p = 2` and `p = 3` below. -/

/-- Iterating shift-by-`p` invariance. -/
lemma iterate_period {n p : ℕ} {s : Cfg n} (h : ∀ i, s (i + (p : ZMod n)) = s i) :
    ∀ (k : ℕ) (i : ZMod n), s (i + (p : ZMod n) * (k : ZMod n)) = s i := by
  intro k
  induction k with
  | zero => intro i; simp
  | succ m ih =>
      intro i
      have hstep : i + (p : ZMod n) * ((m + 1 : ℕ) : ZMod n)
          = (i + (p : ZMod n) * (m : ZMod n)) + (p : ZMod n) := by
        push_cast
        ring
      rw [hstep, h, ih]

/-- If the spatial period `p` is invertible modulo `n`, shift-by-`p` invariance
upgrades to shift-by-one invariance. -/
lemma shift_one_of_period_coprime {n p : ℕ} (hn : n ≠ 0) (hcop : Nat.Coprime p n) {s : Cfg n}
    (h : ∀ i, s (i + (p : ZMod n)) = s i) : ∀ i, s (i + 1) = s i := by
  haveI : NeZero n := ⟨hn⟩
  obtain ⟨v, hv⟩ := isUnit_iff_exists_inv.1 ((ZMod.isUnit_iff_coprime p n).2 hcop)
  intro i
  have hcast : ((p : ℕ) : ZMod n) * ((v.val : ℕ) : ZMod n) = 1 := by
    simpa [ZMod.natCast_val, ZMod.cast_id] using hv
  have hiter := iterate_period h v.val i
  rwa [hcast] at hiter

/-- A shift-invariant configuration on a finite ring is constant. -/
lemma constant_of_shift_one {n : ℕ} [NeZero n] {s : Cfg n} (h : ∀ i, s (i + 1) = s i) :
    ∀ i, s i = s 0 := by
  have key : ∀ k : ℕ, s ((k : ℕ) : ZMod n) = s 0 := by
    intro k
    induction k with
    | zero => simp
    | succ m ih =>
        have e : ((m + 1 : ℕ) : ZMod n) = ((m : ℕ) : ZMod n) + 1 := by push_cast; ring
        rw [e, h, ih]
  intro i
  have hi : ((i.val : ℕ) : ZMod n) = i := by simp [ZMod.natCast_val, ZMod.cast_id]
  have := key i.val
  rwa [hi] at this

/-- Two configurations of spatial period two agreeing on the seed cells `0` and
`1` are equal. -/
lemma eq_of_period_two_seed {n : ℕ} [NeZero n] {s t : Cfg n}
    (hs : ∀ i, s (i + 2) = s i) (ht : ∀ i, t (i + 2) = t i)
    (h0 : s 0 = t 0) (h1 : s 1 = t 1) : s = t := by
  have key : ∀ k : ℕ, s ((k : ℕ) : ZMod n) = t ((k : ℕ) : ZMod n) ∧
      s (((k + 1 : ℕ) : ℕ) : ZMod n) = t (((k + 1 : ℕ) : ℕ) : ZMod n) := by
    intro k
    induction k with
    | zero => simpa using ⟨h0, h1⟩
    | succ m ih =>
        obtain ⟨hm, hm1⟩ := ih
        refine ⟨by simpa using hm1, ?_⟩
        have e : ((m + 1 + 1 : ℕ) : ZMod n) = ((m : ℕ) : ZMod n) + 2 := by push_cast; ring
        rw [e, hs, ht, hm]
  funext i
  have hi : ((i.val : ℕ) : ZMod n) = i := by simp [ZMod.natCast_val, ZMod.cast_id]
  have hk := (key i.val).1
  rwa [hi] at hk

/-- A rule is *additive* when its local rule is `𝔽₂`-linear in the three
arguments; these are exactly the rules whose fixed-point locus is a linear
subvariety. -/
def IsAdditive (rule : ℕ) : Prop :=
  ∀ l c r l' c' r' : ZMod 2,
    localRuleZ rule (l + l') (c + c') (r + r') =
      localRuleZ rule l c r + localRuleZ rule l' c' r'

/-- An additive local rule kills the zero neighbourhood. -/
lemma IsAdditive.localRuleZ_zero {rule : ℕ} (h : IsAdditive rule) :
    localRuleZ rule 0 0 0 = 0 := by
  have hh := h 0 0 0 0 0 0
  simp only [add_zero] at hh
  exact add_eq_left.mp hh.symm

/-- For an additive rule, the fixed-point variety is an `𝔽₂`-subspace of `𝔸ⁿ`. -/
def IsAdditive.fixedSubmodule {rule : ℕ} (h : IsAdditive rule) (n : ℕ) :
    Submodule (ZMod 2) (Cfg n) where
  carrier := fixedSet rule n
  add_mem' := by
    intro a b ha hb
    rw [mem_fixedSet_iff] at ha hb ⊢
    intro i
    show localRuleZ rule (a (i - 1) + b (i - 1)) (a i + b i) (a (i + 1) + b (i + 1)) = a i + b i
    rw [h, ha i, hb i]
  zero_mem' := by
    show (0 : Cfg n) ∈ fixedSet rule n
    rw [mem_fixedSet_iff]
    intro i
    simpa using h.localRuleZ_zero
  smul_mem' := by
    intro c a ha
    fin_cases c
    · show (0 : ZMod 2) • a ∈ fixedSet rule n
      rw [zero_smul]
      rw [mem_fixedSet_iff]
      intro i
      simpa using h.localRuleZ_zero
    · show (1 : ZMod 2) • a ∈ fixedSet rule n
      rwa [one_smul]

/-- `V(rule, n)` *has dimension* `d` when it is a linear subvariety of affine
`n`-space of `𝔽₂`-dimension `d`. -/
def HasFixedDim (rule n d : ℕ) : Prop :=
  ∃ W : Submodule (ZMod 2) (Cfg n),
    (W : Set (Cfg n)) = fixedSet rule n ∧ Module.finrank (ZMod 2) W = d

/-- The dimension of a fixed-point variety is well defined when it exists. -/
lemma hasFixedDim_unique {rule n d d' : ℕ} (h : HasFixedDim rule n d)
    (h' : HasFixedDim rule n d') : d = d' := by
  obtain ⟨W, hW, hd⟩ := h
  obtain ⟨W', hW', hd'⟩ := h'
  have : W = W' := SetLike.coe_injective (hW.trans hW'.symm)
  subst this
  exact hd.symm.trans hd'

/-- Evaluation of a configuration at the two seed cells `0` and `1`. -/
def seedPair (n : ℕ) : Cfg n →ₗ[ZMod 2] (Fin 2 → ZMod 2) where
  toFun s := ![s 0, s 1]
  map_add' a b := by
    funext j
    fin_cases j <;> simp
  map_smul' c a := by
    funext j
    fin_cases j <;> simp

/-- **Seed rigidity caps the dimension at two.**  If a stationary configuration
is determined by its values at the two cells `0` and `1`, the fixed-point
variety cannot have dimension more than `2`, however large the ring is. -/
theorem hasFixedDim_le_two_of_seed_rigid {rule n : ℕ} [NeZero n]
    (hrig : ∀ s ∈ fixedSet rule n, s 0 = 0 → s 1 = 0 → s = 0) {d : ℕ}
    (h : HasFixedDim rule n d) : d ≤ 2 := by
  obtain ⟨W, hW, hd⟩ := h
  have hinj : Function.Injective ⇑((seedPair n).comp W.subtype) := by
    rw [← LinearMap.ker_eq_bot, Submodule.eq_bot_iff]
    rintro ⟨s, hsW⟩ hs
    have hker := LinearMap.mem_ker.1 hs
    have hs0 : s 0 = 0 := by simpa [seedPair] using congrFun hker 0
    have hs1 : s 1 = 0 := by simpa [seedPair] using congrFun hker 1
    have hmem : s ∈ fixedSet rule n := by rw [← hW]; exact hsW
    simpa [Subtype.ext_iff] using hrig s hmem hs0 hs1
  have hle := LinearMap.finrank_le_finrank_of_injective (f := (seedPair n).comp W.subtype) hinj
  rw [hd] at hle
  simpa using hle

/-- The cardinality of a fixed-point variety of dimension `d` is `2 ^ d`. -/
theorem card_fixedSet_of_hasFixedDim {rule n d : ℕ} [NeZero n] (h : HasFixedDim rule n d) :
    Nat.card (fixedSet rule n) = 2 ^ d := by
  obtain ⟨W, hW, hd⟩ := h
  haveI : Fintype W := Fintype.ofFinite _
  have hcard : Fintype.card W = 2 ^ d := by
    have := Module.card_eq_pow_finrank (K := ZMod 2) (V := W)
    simpa [hd, ZMod.card] using this
  have hco : Nat.card ((W : Set (Cfg n))) = Nat.card W := rfl
  rw [← hW, hco, Nat.card_eq_fintype_card, hcard]

section Rule204

/-- Rule 204 is the identity: it is the projection onto the centre cell. -/
lemma rule204_localRuleZ : ∀ l c r : ZMod 2, localRuleZ 204 l c r = c := by decide

/-- The identity rule fixes every configuration: its variety is all of `𝔸ⁿ`. -/
theorem rule204_fixedSet_univ (n : ℕ) : fixedSet 204 n = Set.univ := by
  ext s
  simp only [Set.mem_univ, iff_true, mem_fixedSet_iff]
  intro i
  exact rule204_localRuleZ _ _ _

/-- Rule 204 is additive. -/
lemma rule204_isAdditive : IsAdditive 204 := by
  intro l c r l' c' r'
  simp [rule204_localRuleZ]

/-- The identity rule attains the maximal possible dimension `n`. -/
theorem rule204_hasFixedDim (n : ℕ) [NeZero n] : HasFixedDim 204 n n := by
  refine ⟨⊤, ?_, ?_⟩
  · simp [rule204_fixedSet_univ]
  · rw [finrank_top]
    simp

end Rule204

section Rule0

/-- Rule 0 sends everything to the zero configuration. -/
lemma rule0_localRuleZ : ∀ l c r : ZMod 2, localRuleZ 0 l c r = 0 := by decide

/-- The null rule has the single fixed configuration `0`. -/
theorem rule0_fixedSet (n : ℕ) : fixedSet 0 n = {0} := by
  ext s
  rw [mem_fixedSet_iff]
  constructor
  · intro h
    funext i
    exact (h i).symm.trans (rule0_localRuleZ _ _ _)
  · rintro rfl i
    simp [rule0_localRuleZ]

/-- Rule 0 is additive. -/
lemma rule0_isAdditive : IsAdditive 0 := by
  intro l c r l' c' r'
  simp [rule0_localRuleZ]

/-- Rule 0 (Wolfram class 1) has fixed-point dimension `0`. -/
theorem rule0_hasFixedDim_zero (n : ℕ) : HasFixedDim 0 n 0 := by
  refine ⟨⊥, ?_, ?_⟩
  · rw [rule0_fixedSet]
    simp
  · simp

end Rule0

end ECAFixedVariety