import Mathlib

/-!
# Galois Theory of Cellular Automata: Reversible Dynamics

We formalize the group structure of reversible elementary cellular automata
(ECAs) on periodic binary configurations. An elementary CA has radius 1 and
binary alphabet {0,1}, giving 256 possible local rules (Wolfram numbering).

## Main Results

* `globalMap_rule204_eq_id` — Rule 204 implements the identity map
* `globalMap_rule170_bijective` — Rule 170 (left shift) is bijective
* `globalMap_rule051_bijective` — Rule 51 (complement) is bijective
* `globalMap_rule000_not_injective` — Rule 0 is not injective for n ≥ 2
* `reversible_eca_periodic` — Every config under a reversible CA is periodic
* `shift_complement_comm` — Shift and complement commute as global maps

## Novel Definitions

* `CADynamicalSystem` — A CA viewed as a discrete dynamical system with orbit structure
* `ReversibilityIndex` — Measures how far a rule is from being reversible
-/

namespace GaloisCA

/-! ## Configuration Space and Local Rules -/

/-- Configuration: a periodic binary string of length n -/
abbrev Config (n : ℕ) := Fin n → Bool

/-- An elementary CA local rule maps a 3-cell neighborhood (left, center, right) to a cell value -/
abbrev LocalRule := Bool → Bool → Bool → Bool

/-! ## Cyclic Index Operations on Fin n -/

/-- Right neighbor index (i+1 mod n) -/
def rightIdx {n : ℕ} (hn : 0 < n) (i : Fin n) : Fin n :=
  ⟨(i.val + 1) % n, Nat.mod_lt _ hn⟩

/-- Left neighbor index (i-1 mod n, computed as i+n-1 mod n) -/
def leftIdx {n : ℕ} (hn : 0 < n) (i : Fin n) : Fin n :=
  ⟨(i.val + n - 1) % n, Nat.mod_lt _ hn⟩

/-! ## Global Map -/

/-- The global map induced by a local rule on periodic configurations of size n.
    Each cell's new value is determined by applying the rule to the cell and its neighbors. -/
def globalMap (f : LocalRule) {n : ℕ} (hn : 0 < n)
    (s : Config n) : Config n := fun i =>
  f (s (leftIdx hn i)) (s i) (s (rightIdx hn i))

/-! ## Named Elementary CA Rules (Wolfram Numbering)

The 6 reversible elementary CAs are exactly the rules whose output depends
on a single input variable, composed with an optional negation:
- Center-dependent: Rule 204 (c), Rule 51 (¬c)
- Right-dependent: Rule 170 (r), Rule 85 (¬r)
- Left-dependent: Rule 240 (l), Rule 15 (¬l)
-/

/-- Rule 204: identity — output equals center cell -/
def rule204 : LocalRule := fun _ c _ => c

/-- Rule 170: left shift — output equals right neighbor -/
def rule170 : LocalRule := fun _ _ r => r

/-- Rule 240: right shift — output equals left neighbor -/
def rule240 : LocalRule := fun l _ _ => l

/-- Rule 51: complement — output is NOT of center cell -/
def rule051 : LocalRule := fun _ c _ => !c

/-- Rule 85: complement left shift — output is NOT of right neighbor -/
def rule085 : LocalRule := fun _ _ r => !r

/-- Rule 15: complement right shift — output is NOT of left neighbor -/
def rule015 : LocalRule := fun l _ _ => !l

/-- Rule 0: constant false — all cells become 0 -/
def rule000 : LocalRule := fun _ _ _ => false

/-! ## Novel Definition: CA Dynamical System -/

/-- A cellular automaton dynamical system encapsulates a CA rule
    acting on periodic configurations with orbit and periodicity structure. -/
structure CADynamicalSystem (n : ℕ) where
  /-- The local rule defining the CA -/
  rule : LocalRule
  /-- Proof that the configuration size is positive -/
  pos : 0 < n

/-- The global evolution map of a CA dynamical system -/
def CADynamicalSystem.evolve {n : ℕ} (ca : CADynamicalSystem n) :
    Config n → Config n :=
  globalMap ca.rule ca.pos

/-- The orbit of a configuration under iterated evolution -/
def CADynamicalSystem.iterateMap {n : ℕ} (ca : CADynamicalSystem n) :
    ℕ → Config n → Config n
  | 0 => id
  | k + 1 => ca.evolve ∘ ca.iterateMap k

/-- A CA is reversible if its global map is bijective -/
def CADynamicalSystem.isReversible {n : ℕ} (ca : CADynamicalSystem n) : Prop :=
  Function.Bijective ca.evolve

/-! ## Novel Definition: Reversibility Index -/

/-- The reversibility index measures the failure of injectivity.
    It counts how many configurations share their image with another
    distinct configuration. For reversible CAs, this is 0. -/
noncomputable def reversibilityIndex {n : ℕ} (f : Config n → Config n) : ℕ :=
  Finset.card (Finset.univ.filter (fun s =>
    ∃ t : Config n, t ≠ s ∧ f t = f s))

/-! ## Cyclic Index Lemmas -/

/-
Left and right index operations are inverse: leftIdx ∘ rightIdx = id
-/
theorem leftIdx_rightIdx {n : ℕ} (hn : 0 < n) (i : Fin n) :
    leftIdx hn (rightIdx hn i) = i := by
  -- By definition of `leftIdx` and `rightIdx`, we have `leftIdx hn (rightIdx hn i) = i`.
  apply Fin.ext
  simp [leftIdx, rightIdx];
  rcases n with ( _ | _ | n ) <;> norm_num at *;
  simp +arith +decide [ Nat.mod_eq_of_lt ];
  norm_num [ ( by ring : n + i + 2 = n + 2 + i ) ];
  exact Fin.is_le i

/-
Right and left index operations are inverse: rightIdx ∘ leftIdx = id
-/
theorem rightIdx_leftIdx {n : ℕ} (hn : 0 < n) (i : Fin n) :
    rightIdx hn (leftIdx hn i) = i := by
  rcases n with ( _ | _ | n ) <;> norm_num [ Fin.ext_iff, leftIdx, rightIdx ] at *;
  · contradiction;
  · norm_num [ add_assoc, Nat.mod_eq_of_lt ]

/-- rightIdx is injective -/
theorem rightIdx_injective {n : ℕ} (hn : 0 < n) : Function.Injective (rightIdx hn) := by
  intro a b hab
  have := congr_arg (leftIdx hn) hab
  rwa [leftIdx_rightIdx, leftIdx_rightIdx] at this

/-- leftIdx is injective -/
theorem leftIdx_injective {n : ℕ} (hn : 0 < n) : Function.Injective (leftIdx hn) := by
  intro a b hab
  have := congr_arg (rightIdx hn) hab
  rwa [rightIdx_leftIdx, rightIdx_leftIdx] at this

/-- rightIdx is surjective -/
theorem rightIdx_surjective {n : ℕ} (hn : 0 < n) : Function.Surjective (rightIdx hn) :=
  fun b => ⟨leftIdx hn b, rightIdx_leftIdx hn b⟩

/-- leftIdx is surjective -/
theorem leftIdx_surjective {n : ℕ} (hn : 0 < n) : Function.Surjective (leftIdx hn) :=
  fun b => ⟨rightIdx hn b, leftIdx_rightIdx hn b⟩

/-- rightIdx is bijective -/
theorem rightIdx_bijective {n : ℕ} (hn : 0 < n) : Function.Bijective (rightIdx hn) :=
  ⟨rightIdx_injective hn, rightIdx_surjective hn⟩

/-- leftIdx is bijective -/
theorem leftIdx_bijective {n : ℕ} (hn : 0 < n) : Function.Bijective (leftIdx hn) :=
  ⟨leftIdx_injective hn, leftIdx_surjective hn⟩

/-! ## Rule Characterizations -/

/-- Rule 204 gives the identity global map -/
theorem globalMap_rule204_eq_id {n : ℕ} (hn : 0 < n) (s : Config n) :
    globalMap rule204 hn s = s := by
  ext i; simp [globalMap, rule204]

/-- Rule 170 gives precomposition with rightIdx (left cyclic shift) -/
theorem globalMap_rule170_eq {n : ℕ} (hn : 0 < n) (s : Config n) :
    globalMap rule170 hn s = s ∘ rightIdx hn := by
  ext i; simp [globalMap, rule170]

/-- Rule 240 gives precomposition with leftIdx (right cyclic shift) -/
theorem globalMap_rule240_eq {n : ℕ} (hn : 0 < n) (s : Config n) :
    globalMap rule240 hn s = s ∘ leftIdx hn := by
  ext i; simp [globalMap, rule240]

/-- Rule 51 gives pointwise negation -/
theorem globalMap_rule051_eq {n : ℕ} (hn : 0 < n) (s : Config n) :
    globalMap rule051 hn s = fun i => !(s i) := by
  ext i; simp [globalMap, rule051]

/-! ## Bijection Proofs for Reversible Rules -/

/-
Rule 170 (left shift) is bijective
-/
theorem globalMap_rule170_bijective {n : ℕ} (hn : 0 < n) :
    Function.Bijective (globalMap rule170 hn) := by
  constructor;
  · intro s t h_eq;
    ext i;
    have := congr_fun h_eq ( leftIdx hn i ) ; simp_all +decide [ globalMap_rule170_eq ];
    rwa [ rightIdx_leftIdx ] at this;
  · intro s
    use s ∘ leftIdx hn
    simp [globalMap_rule170_eq, rightIdx_leftIdx];
    exact funext fun x => by simp +decide [ leftIdx_rightIdx ] ;

/-
Rule 240 (right shift) is bijective
-/
theorem globalMap_rule240_bijective {n : ℕ} (hn : 0 < n) :
    Function.Bijective (globalMap rule240 hn) := by
  rw [ Function.bijective_iff_has_inverse ];
  use globalMap rule170 hn;
  constructor <;> intro s <;> ext i <;> simp +decide [ globalMap_rule170_eq, globalMap_rule240_eq, leftIdx_rightIdx, rightIdx_leftIdx ]

/-
Rule 51 (complement) is an involution
-/
theorem globalMap_rule051_involutive {n : ℕ} (hn : 0 < n) :
    Function.Involutive (globalMap rule051 hn) := by
  intro s; ext i; simp +decide [ globalMap_rule051_eq hn s, globalMap_rule051_eq hn ( fun i ↦ !s i ) ] ;

/-- Rule 51 is bijective (immediate from involutive) -/
theorem globalMap_rule051_bijective {n : ℕ} (hn : 0 < n) :
    Function.Bijective (globalMap rule051 hn) :=
  (globalMap_rule051_involutive hn).bijective

/-
Rule 170 and Rule 240 are inverses
-/
theorem globalMap_rule170_rule240_inverse {n : ℕ} (hn : 0 < n) (s : Config n) :
    globalMap rule170 hn (globalMap rule240 hn s) = s := by
  simp +decide [ funext_iff, rule170, rule240 ];
  exact fun x => congr_arg s ( leftIdx_rightIdx hn x )

/-
Rule 240 and Rule 170 are inverses
-/
theorem globalMap_rule240_rule170_inverse {n : ℕ} (hn : 0 < n) (s : Config n) :
    globalMap rule240 hn (globalMap rule170 hn s) = s := by
  ext i; exact (by
  convert congr_arg s ( rightIdx_leftIdx hn i ) using 1)

/-! ## Non-Reversibility of Rule 0 -/

/-- Rule 0 maps all configurations to the constant-false configuration -/
theorem globalMap_rule000_const {n : ℕ} (hn : 0 < n) (s : Config n) :
    globalMap rule000 hn s = fun _ => false := by
  ext i; simp [globalMap, rule000]

/-
Rule 0 is not injective for n ≥ 1 (since all configs map to the same thing)
-/
theorem globalMap_rule000_not_injective {n : ℕ} (hn : 2 ≤ n) :
    ¬ Function.Injective (globalMap rule000 (by omega : 0 < n)) := by
  norm_num [ Function.Injective ];
  use fun _ => false, fun _ => true;
  simp +decide [ globalMap_rule000_const ];
  exact fun h => by have := congr_fun h ⟨ 0, by linarith ⟩ ; contradiction;

/-! ## Commutativity: Shift and Complement Commute -/

/-- The complement operation on configurations -/
def complementConfig {n : ℕ} (s : Config n) : Config n := fun i => !(s i)

/-- The left shift operation on configurations -/
def leftShift {n : ℕ} (hn : 0 < n) (s : Config n) : Config n :=
  s ∘ rightIdx hn

/-
Complement is an involution
-/
theorem complementConfig_involutive {n : ℕ} :
    Function.Involutive (@complementConfig n) := by
  exact fun x => by ext; simp +decide [ complementConfig ] ;

/-
Left shift and complement commute as operations on configurations
-/
theorem shift_complement_comm {n : ℕ} (hn : 0 < n) (s : Config n) :
    leftShift hn (complementConfig s) = complementConfig (leftShift hn s) := by
  exact funext fun i => rfl

/-! ## Periodicity under Reversible CAs -/

/-
Every configuration under a bijective map on a finite type is periodic.
    This is a fundamental consequence of the pigeonhole principle:
    the orbit {s, f(s), f²(s), ...} in a finite set must eventually repeat.
-/
theorem reversible_eca_periodic {n : ℕ} (hn : 0 < n)
    (f : Config n → Config n) (hf : Function.Bijective f) (s : Config n) :
    ∃ p : ℕ, 0 < p ∧ f^[p] s = s := by
  -- By the pigeonhole principle, � since� the configuration space is finite, there must exist distinct positive integers $i$ and $j$ such that $f^i(s) = f^j(s)$.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j : ℕ, 0 < i ∧ i < j ∧ f^[i] s = f^[j] s := by
    by_contra! h;
    exact absurd ( Set.infinite_range_of_injective ( show Function.Injective ( fun i : ℕ => f^[i+1] s ) from fun i j hij => le_antisymm ( not_lt.1 fun hi => h _ _ ( Nat.succ_pos _ ) ( Nat.succ_lt_succ hi ) hij.symm ) ( not_lt.1 fun hj => h _ _ ( Nat.succ_pos _ ) ( Nat.succ_lt_succ hj ) hij ) ) ) ( Set.not_infinite.mpr <| Set.toFinite _ );
  -- Since $f$ is bijective, we can apply $f^{-1}$ repeatedly to both sides of $f^i(s) = f^j(s)$ to get $s = f^{j-i}(s)$.
  have h_inv : f^[j-i] s = s := by
    have h_inv : f^[i] (f^[j-i] s) = f^[i] s := by
      rw [ ← Function.iterate_add_apply, add_tsub_cancel_of_le h_eq.1.le, h_eq.2 ];
    exact hf.injective.iterate i h_inv;
  grind +revert

/-! ## Reversibility Index Properties -/

/-
The reversibility index of a bijective map is 0
-/
theorem reversibilityIndex_eq_zero_of_bijective {n : ℕ}
    (f : Config n → Config n) (hf : Function.Bijective f) :
    reversibilityIndex f = 0 := by
  unfold reversibilityIndex;
  simp +decide [ hf.injective.eq_iff ]

/-
The reversibility index of a constant map on a space with ≥ 2 elements is positive
-/
theorem reversibilityIndex_pos_of_const {n : ℕ} (hn : 2 ≤ n)
    (c : Config n) :
    0 < reversibilityIndex (fun _ : Config n => c) := by
  -- Since $n \geq 2$, there are at least two distinct configurations in $\text{Config } n$.
  have h_distinct : ∃ s t : Config n, s ≠ t := by
    exact ⟨ fun _ => Bool.true, fun _ => Bool.false, fun h => by have := congr_fun h ⟨ 0, by linarith ⟩ ; simp +decide at this ⟩;
  obtain ⟨ s, t, hst ⟩ := h_distinct; exact Finset.card_pos.mpr ⟨ s, Finset.mem_filter.mpr ⟨ Finset.mem_univ _, t, hst.symm, by simp +decide ⟩ ⟩ ;

/-! ## Structure Theorem: Reversible ECA Classification -/

/-- A local rule is "single-input" if the output depends on exactly one of l, c, r,
    possibly composed with negation. This characterizes the reversible elementary CAs. -/
def isSingleInput (f : LocalRule) : Prop :=
  (∃ g : Bool → Bool, Function.Bijective g ∧ ∀ l c r, f l c r = g l) ∨
  (∃ g : Bool → Bool, Function.Bijective g ∧ ∀ l c r, f l c r = g c) ∨
  (∃ g : Bool → Bool, Function.Bijective g ∧ ∀ l c r, f l c r = g r)

/-
Every single-input rule with a bijective function gives a bijective global map
-/
theorem singleInput_bijective {n : ℕ} (hn : 0 < n) (f : LocalRule)
    (hf : isSingleInput f) :
    Function.Bijective (globalMap f hn) := by
  rcases hf with ( ⟨ g, hg, hg' ⟩ | ⟨ g, hg, hg' ⟩ | ⟨ g, hg, hg' ⟩ );
  · -- In this case, the global map is � (�fun s => g ∘ s ∘ leftIdx hn).
    have h_global_map : globalMap f hn = fun s => g ∘ s ∘ leftIdx hn := by
      ext s i; simp +decide [ hg', globalMap ] ;
    simp_all +decide [ Function.Bijective ];
    constructor;
    · intro s t h_eq;
      ext i; have := congr_fun h_eq ( rightIdx hn i ) ; simp_all +decide [ Function.comp ] ;
      simp_all +decide [ leftIdx_rightIdx ];
      cases h : s i <;> cases h' : t i <;> aesop;
    · intro s; use fun i => g.invFun ( s ( rightIdx hn i ) ) ; ext i; simp +decide [ hg.2, Function.invFun_eq ( hg.2 _ ) ] ;
      rw [ rightIdx_leftIdx ];
  · have h_global : globalMap f hn = fun s => g ∘ s := by
      ext s i; simp +decide [ hg', globalMap ] ;
    rw [ h_global ];
    exact ⟨ fun s t h => funext fun i => hg.injective <| congr_fun h i, fun s => ⟨ fun i => hg.surjective ( s i ) |> Classical.choose, funext fun i => hg.surjective ( s i ) |> Classical.choose_spec ⟩ ⟩;
  · -- Since $g$ is bijective, the map $s \mapsto g \circ s \circ rightIdx$ is also bijective.
    have h_bijective : Function.Bijective (fun s : Fin n → Bool => g ∘ s ∘ rightIdx hn) := by
      constructor;
      · intro s t h_eq;
        simp_all +decide [ funext_iff, Function.Injective.eq_iff hg.injective ];
        intro x; specialize h_eq ( leftIdx hn x ) ; simp_all +decide [ rightIdx_leftIdx ] ;
      · intro t;
        cases' hg with hg₁ hg₂;
        choose f hf using hg₂;
        exact ⟨ fun i => f ( t ( leftIdx hn i ) ), funext fun i => by simp +decide [ hf, leftIdx_rightIdx hn i ] ⟩;
    convert h_bijective using 1;
    ext s i; simp +decide [ hg', globalMap ] ;

/-! ## Conjecture: Universal Reversibility Classification -/

/-- A rule is *universally reversible* if its global map is bijective
    for every configuration size n ≥ 1. -/
def isUniversallyReversible (f : LocalRule) : Prop :=
  ∀ n : ℕ, (hn : 0 < n) → Function.Bijective (globalMap f hn)

/-- **Conjecture (Universal Reversibility Classification)**:
    A local rule is universally reversible (bijective for ALL n) iff it is single-input.

    Note: This is strictly stronger than bijectivity for a fixed n. For example,
    Rule 150 (XOR: f(l,c,r) = l ⊕ c ⊕ r) is bijective on odd-size configs
    but NOT on even-size configs, so it is not universally reversible.

    The forward direction (single-input → universally reversible) is proved
    as `singleInput_bijective`. The converse is the content of this conjecture.

    Falsification test: find a non-single-input rule that is bijective for
    every configuration size n = 1, 2, ..., 20. -/
def universalReversibilityConjecture : Prop :=
  ∀ f : LocalRule, isUniversallyReversible f ↔ isSingleInput f

/-- The forward direction of the universal reversibility conjecture is proved. -/
theorem universalReversibility_of_singleInput (f : LocalRule) (hf : isSingleInput f) :
    isUniversallyReversible f :=
  fun _n hn => singleInput_bijective hn f hf

end GaloisCA