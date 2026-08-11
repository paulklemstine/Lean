import Mathlib
import Novelty.MindToolsBoundedApprehension

/-!
# Translations between proof systems, tight pigeonhole codes, and large antichains

This file continues the resource-bounded reading of "mind tools" begun in
`Catalog/Novelty/MindToolsBoundedApprehension.lean`, which in turn builds on the
extensional framework of `Catalog/Logic/MindTools.lean`.

Three further items of the stated programme are carried out.

* **Interpretations between theories (extension 4).**  A `Translation` between
  proof systems is a conclusion-preserving map of proofs together with a
  monotone bound on the size blow-up.  Translations transport theories
  (`Translation.theory_subset`) and, crucially, transport *bounded apprehension*
  with a computable budget change (`Translation.apprehends_subset`).  This
  separates "expressive convenience" from genuine cognitive extension: a budget
  gap that survives every monotone bound is exactly an obstruction to
  translation (`not_translation_of_apprehension_gap`).

* **Tightness of the counting certificate (extension 3).**  The pigeonhole
  certificate of the previous file guarantees an inaccessible sentence below
  `2 ^ (b + 1)`.  Here the bound is shown to be *exactly attained*: the binary
  numeral code `bcode` apprehends, at budget `b`, precisely the numbers
  `< 2 ^ (b + 1) - 1`, so its least inaccessible sentence is `2 ^ (b + 1) - 1`
  (`bcode_isLeast_not_apprehended`).

* **Antichains of every size (extension 7, quantitative).**  For any index type
  the singleton theories are pairwise incomparable while being ordinal-ranked,
  hence well-founded: well-foundedness of a hierarchy of tools never implies
  comparability, no matter how many tools are present
  (`exists_ordinalRanked_antichain`).
-/

namespace MindTools
namespace Bounded

universe u

variable {Sentence : Type u}

/-! ## Translations (interpretations) between proof systems -/

/-- A **translation** of proof systems: a map on derivations preserving
conclusions, whose size blow-up is controlled by a monotone bound.  This is the
resource-sensitive analogue of an interpretation of theories. -/
structure Translation (P Q : ProofSystem Sentence) where
  /-- The map on derivations. -/
  map : P.Proof → Q.Proof
  /-- Translation preserves what is proved. -/
  conclusion_map : ∀ p, Q.conclusion (map p) = P.conclusion p
  /-- The size blow-up bound. -/
  bound : ℕ → ℕ
  /-- The bound is monotone. -/
  bound_mono : Monotone bound
  /-- The blow-up really is bounded. -/
  size_map_le : ∀ p, Q.size (map p) ≤ bound (P.size p)

namespace Translation

variable {P Q R : ProofSystem Sentence}

/-- The identity translation, with no blow-up. -/
def id (P : ProofSystem Sentence) : Translation P P where
  map := _root_.id
  conclusion_map _ := rfl
  bound := _root_.id
  bound_mono := monotone_id
  size_map_le _ := le_rfl

/-- Translations compose, the bounds composing as well. -/
def comp (t : Translation P Q) (u : Translation Q R) : Translation P R where
  map := u.map ∘ t.map
  conclusion_map p := by
    simp [u.conclusion_map, t.conclusion_map]
  bound := u.bound ∘ t.bound
  bound_mono := u.bound_mono.comp t.bound_mono
  size_map_le p :=
    (u.size_map_le (t.map p)).trans (u.bound_mono (t.size_map_le p))

/-- A translation makes the target theory contain the source theory: this is the
extensional shadow of an interpretation. -/
theorem theory_subset (t : Translation P Q) :
    (theory P).provable ⊆ (theory Q).provable := by
  rintro s ⟨p, rfl⟩
  exact ⟨t.map p, t.conclusion_map p⟩

/-- The essential resource-sensitive statement: apprehension at budget `b` in
the source is apprehension at budget `bound b` in the target. -/
theorem apprehends_subset (t : Translation P Q) (b : ℕ) :
    (apprehends P b).direct ⊆ (apprehends Q (t.bound b)).direct := by
  rintro s ⟨p, hp, rfl⟩
  exact ⟨t.map p, (t.size_map_le p).trans (t.bound_mono hp), t.conclusion_map p⟩

/-- Consequently a translation with bound `f` collapses every apprehension gap
of shape `(b, f b)`. -/
theorem not_apprehension_gap (t : Translation P Q) {b : ℕ} {s : Sentence}
    (hs : s ∈ (apprehends P b).direct) : s ∈ (apprehends Q (t.bound b)).direct :=
  t.apprehends_subset b hs

end Translation

/-- **Certificate for non-translatability.**  If some sentence is apprehended in
`P` within budget `b` but is not apprehended in `Q` within budget `f b`, then no
translation of `P` into `Q` has size bound `f`.  A surviving budget gap is thus
exactly an obstruction to bounded interpretation — the precise sense in which a
cognitive separation is more than expressive convenience. -/
theorem not_translation_of_apprehension_gap {P Q : ProofSystem Sentence}
    (f : ℕ → ℕ) {b : ℕ} {s : Sentence}
    (hs : s ∈ (apprehends P b).direct) (hgap : s ∉ (apprehends Q (f b)).direct) :
    ¬ ∃ t : Translation P Q, t.bound = f := by
  rintro ⟨t, rfl⟩
  exact hgap (t.apprehends_subset b hs)

/-- Under a translation the target is a mind tool for the source's bounded
profile as soon as it proves one sentence outside the translated budget. -/
theorem isMindTool_of_translation {P Q : ProofSystem Sentence}
    (t : Translation P Q) (b : ℕ) {s : Sentence}
    (hs : s ∈ (theory Q).provable) (hs' : s ∉ (apprehends Q (t.bound b)).direct) :
    IsMindTool (theory Q) (apprehends P b) := by
  refine isMindTool_of_witness _ _ ?_ hs (fun hmem => hs' (t.apprehends_subset b hmem))
  exact (t.apprehends_subset b).trans (apprehends_subset_theory Q _)

/-! ## A code attaining the pigeonhole bound -/

/-- The numeral value of a bit string, least significant bit first, prefixed by
an implicit leading `1`.  Thus `val` is a bijection from strings of length `k`
onto the interval `[2 ^ k, 2 ^ (k + 1))`. -/
def val : List Bool → ℕ
  | [] => 1
  | b :: t => 2 * val t + (if b then 1 else 0)

@[simp] theorem val_nil : val [] = 1 := rfl

@[simp] theorem val_cons (b : Bool) (t : List Bool) :
    val (b :: t) = 2 * val t + (if b then 1 else 0) := rfl

theorem val_pos (l : List Bool) : 0 < val l := by
  induction l with
  | nil => simp
  | cons b t ih => simp only [val_cons]; omega

theorem val_lt (l : List Bool) : val l < 2 ^ (l.length + 1) := by
  induction l with
  | nil => simp
  | cons b t ih =>
      have h : (2:ℕ) ^ (t.length + 1 + 1) = 2 * 2 ^ (t.length + 1) := by ring
      have hb : (if b then 1 else 0) ≤ 1 := by cases b <;> simp
      simp only [val_cons, List.length_cons]
      omega

/-- The inverse of `val`: the bit string of a positive numeral. -/
def enc (v : ℕ) : List Bool :=
  if h : v ≤ 1 then [] else (decide (v % 2 = 1)) :: enc (v / 2)
  decreasing_by exact Nat.div_lt_self (by omega) (by norm_num)

theorem enc_of_le_one {v : ℕ} (h : v ≤ 1) : enc v = [] := by
  rw [enc]; simp [h]

theorem enc_of_one_lt {v : ℕ} (h : 1 < v) :
    enc v = (decide (v % 2 = 1)) :: enc (v / 2) := by
  rw [enc]; simp [Nat.not_le.2 h]

theorem val_enc (v : ℕ) (hv : 0 < v) : val (enc v) = v := by
  induction v using Nat.strong_induction_on with
  | _ v ih =>
    rcases le_or_gt v 1 with h | h
    · have : v = 1 := by omega
      simp [this, enc_of_le_one]
    · have hlt : v / 2 < v := Nat.div_lt_self hv (by norm_num)
      have hpos : 0 < v / 2 := Nat.div_pos (by omega) (by norm_num)
      rw [enc_of_one_lt h, val_cons, ih _ hlt hpos]
      by_cases hmod : v % 2 = 1
      · rw [if_pos (by simp [hmod])]
        omega
      · rw [if_neg (by simp [hmod])]
        omega

theorem two_pow_length_enc_le (v : ℕ) (hv : 0 < v) : 2 ^ (enc v).length ≤ v := by
  induction v using Nat.strong_induction_on with
  | _ v ih =>
    rcases le_or_gt v 1 with h | h
    · have : v = 1 := by omega
      simp [this, enc_of_le_one]
    · have hlt : v / 2 < v := Nat.div_lt_self hv (by norm_num)
      have hpos : 0 < v / 2 := Nat.div_pos (by omega) (by norm_num)
      have := ih _ hlt hpos
      rw [enc_of_one_lt h, List.length_cons, pow_succ]
      omega

theorem length_enc_le {v b : ℕ} (hv : 0 < v) (hb : v < 2 ^ (b + 1)) :
    (enc v).length ≤ b := by
  have h1 := two_pow_length_enc_le v hv
  have h2 : (2:ℕ) ^ (enc v).length < 2 ^ (b + 1) := lt_of_le_of_lt h1 hb
  have := (Nat.pow_lt_pow_iff_right (a := 2) (by norm_num)).1 h2
  omega

/-- The **binary numeral code**: a proof of `n` is the bit string of `n + 1`.
This is a bijective code, so it attains the pigeonhole bound exactly. -/
def bcode : List Bool → ℕ := fun l => val l - 1

/-- At budget `b`, the numeral code apprehends exactly the numbers below
`2 ^ (b + 1) - 1` — precisely as many sentences as there are proofs. -/
theorem bcode_apprehends (b : ℕ) :
    (apprehends (binary bcode) b).direct = {n : ℕ | n < 2 ^ (b + 1) - 1} := by
  ext n
  constructor
  · rintro ⟨p, hp, rfl⟩
    have hlen : p.length ≤ b := hp
    have h1 : val p < 2 ^ (p.length + 1) := val_lt p
    have h2 : (2:ℕ) ^ (p.length + 1) ≤ 2 ^ (b + 1) :=
      Nat.pow_le_pow_right (by norm_num) (by omega)
    have h3 : 0 < val p := val_pos p
    show val p - 1 < 2 ^ (b + 1) - 1
    omega
  · intro hn
    have hpow : (1:ℕ) ≤ 2 ^ (b + 1) := Nat.one_le_two_pow
    have hn' : n + 1 < 2 ^ (b + 1) := by
      simp only [Set.mem_setOf_eq] at hn
      omega
    refine ⟨enc (n + 1), length_enc_le (by omega) hn', ?_⟩
    show val (enc (n + 1)) - 1 = n
    rw [val_enc _ (by omega)]
    omega

/-- The numeral code proves every sentence. -/
theorem bcode_theory : (theory (binary bcode)).provable = Set.univ := by
  ext n
  refine ⟨fun _ => trivial, fun _ => ⟨enc (n + 1), ?_⟩⟩
  show val (enc (n + 1)) - 1 = n
  rw [val_enc _ (by omega)]
  omega

/-- **The pigeonhole bound is tight.**  For the numeral code the least sentence
inaccessible at budget `b` is exactly `2 ^ (b + 1) - 1`, the value furnished by
the counting argument `exists_lt_two_pow_not_apprehended`. -/
theorem bcode_isLeast_not_apprehended (b : ℕ) :
    IsLeast {n : ℕ | n ∉ (apprehends (binary bcode) b).direct} (2 ^ (b + 1) - 1) := by
  have h1 : (1:ℕ) ≤ 2 ^ (b + 1) := Nat.one_le_two_pow
  constructor
  · simp only [bcode_apprehends, Set.mem_setOf_eq, not_lt, Set.mem_setOf_eq]
    omega
  · intro n hn
    by_contra hlt
    exact hn (by simp only [bcode_apprehends, Set.mem_setOf_eq]; omega)

/-- The numeral code is an unconditional mind tool at every budget, with the
optimal explicit witness. -/
theorem bcode_isMindTool (b : ℕ) :
    IsMindTool (theory (binary bcode)) (apprehends (binary bcode) b) := by
  refine isMindTool_of_witness _ _ (apprehends_subset_theory _ b)
    (sentence := 2 ^ (b + 1) - 1) ?_ (bcode_isLeast_not_apprehended b).1
  rw [bcode_theory]; trivial

/-- The numeral code's apprehension chain is strictly increasing at *every*
budget: unlike the redundant length code, no budget is wasted. -/
theorem bcode_strictMono {b b' : ℕ} (h : b < b') :
    (apprehends (binary bcode) b).direct ⊂ (apprehends (binary bcode) b').direct := by
  have hmono : (2:ℕ) ^ (b + 1) ≤ 2 ^ (b' + 1) :=
    Nat.pow_le_pow_right (by norm_num) (by omega)
  have hstrict : (2:ℕ) ^ (b + 1) < 2 ^ (b' + 1) :=
    Nat.pow_lt_pow_right (by norm_num) (by omega)
  rw [bcode_apprehends, bcode_apprehends]
  constructor
  · intro n hn
    simp only [Set.mem_setOf_eq] at *
    omega
  · intro hsub
    have h1 : (1:ℕ) ≤ 2 ^ (b + 1) := Nat.one_le_two_pow
    have hmem : (2 ^ (b + 1) - 1) ∈ {n : ℕ | n < 2 ^ (b' + 1) - 1} := by
      simp only [Set.mem_setOf_eq]
      omega
    have hcon := hsub hmem
    simp only [Set.mem_setOf_eq] at hcon
    omega

/-! ## An exponential asymmetry between two codes for the same theory -/

/-- The unary length code translates into the optimal numeral code for free:
there is a translation with the identity bound.  (Both systems prove exactly the
sentences `ℕ`, so no extensional comparison sees any difference.) -/
def lengthToBcode : Translation lengthSystem (binary bcode) where
  map p := enc (p.length + 1)
  conclusion_map p := by
    show val (enc (p.length + 1)) - 1 = p.length
    rw [val_enc _ (by omega)]
    omega
  bound := _root_.id
  bound_mono := monotone_id
  size_map_le p := by
    have h1 : 2 ^ (enc (p.length + 1)).length ≤ p.length + 1 :=
      two_pow_length_enc_le _ (by omega)
    have h2 : (enc (p.length + 1)).length < 2 ^ (enc (p.length + 1)).length :=
      Nat.lt_two_pow_self
    show (enc (p.length + 1)).length ≤ p.length
    omega

/-- **Exponential blow-up in the other direction.**  Any translation of the
optimal numeral code into the unary length code must inflate budgets
exponentially: `bound b ≥ 2 ^ (b + 1) - 2`.  The two proof systems have the very
same extensional theory (all of `ℕ`), so this separation is invisible to the
extensional model of `Catalog/Logic/MindTools.lean` and is detected only by the
resource-bounded reading of apprehension. -/
theorem bcode_to_lengthSystem_bound_ge (t : Translation (binary bcode) lengthSystem)
    (b : ℕ) : 2 ^ (b + 1) - 2 ≤ t.bound b := by
  have h1 : (2:ℕ) ≤ 2 ^ (b + 1) := by
    have : (2:ℕ) ^ 1 ≤ 2 ^ (b + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
    simpa using this
  have hmem : (2 ^ (b + 1) - 2) ∈ (apprehends (binary bcode) b).direct := by
    rw [bcode_apprehends]
    simp only [Set.mem_setOf_eq]
    omega
  have := t.apprehends_subset b hmem
  rwa [lengthSystem_apprehends, Set.mem_Iic] at this

/-- Auxiliary: powers of `2` eventually dominate every fixed power. -/
theorem nat_pow_lt_two_pow_eventually (k : ℕ) : ∃ N : ℕ, ∀ m ≥ N, m ^ k < 2 ^ m := by
  have h := isLittleO_pow_const_const_pow_of_one_lt (R := ℝ) k (r := 2) (by norm_num)
  have h2 := h.def (c := 1 / 2) (by norm_num)
  rw [Filter.eventually_atTop] at h2
  obtain ⟨N, hN⟩ := h2
  refine ⟨N, fun m hm => ?_⟩
  have hm' := hN m hm
  simp only [norm_pow, Real.norm_natCast, Real.norm_ofNat] at hm'
  have hlt : ((m ^ k : ℕ) : ℝ) < ((2 ^ m : ℕ) : ℝ) := by
    push_cast
    have hpos : (0:ℝ) < 2 ^ m := by positivity
    calc (m:ℝ) ^ k ≤ 1 / 2 * 2 ^ m := hm'
      _ < 2 ^ m := by linarith
  exact_mod_cast hlt

/-- Auxiliary: every polynomial in `m` is eventually below `2 ^ (m + 1) - 2`. -/
theorem nat_poly_lt_two_pow_succ (c k : ℕ) :
    ∃ N : ℕ, ∀ m ≥ N, c * m ^ k + c + 2 < 2 ^ (m + 1) := by
  obtain ⟨N, hN⟩ := nat_pow_lt_two_pow_eventually (k + 1)
  refine ⟨max (max N (2 * c + 2)) 1, fun m hm => ?_⟩
  have hm1 : 1 ≤ m := le_trans (le_max_right _ _) hm
  have hmN : N ≤ m := le_trans (le_trans (le_max_left _ _) (le_max_left _ _)) hm
  have hmc : 2 * c + 2 ≤ m := le_trans (le_trans (le_max_right _ _) (le_max_left _ _)) hm
  have h1 : (1:ℕ) ≤ m ^ k := Nat.one_le_pow _ _ (by omega)
  have h2 : c * m ^ k + c + 2 ≤ (2 * c + 2) * m ^ k := by nlinarith
  have h3 : (2 * c + 2) * m ^ k ≤ m * m ^ k := Nat.mul_le_mul_right _ hmc
  have h4 : m * m ^ k = m ^ (k + 1) := by ring
  have h5 : m ^ (k + 1) < 2 ^ m := hN m hmN
  have h6 : (2:ℕ) ^ m < 2 ^ (m + 1) := by
    have e1 : (2:ℕ) ^ (m + 1) = 2 * 2 ^ m := by ring
    have e2 : (0:ℕ) < 2 ^ m := Nat.two_pow_pos m
    omega
  omega

/-- **No polynomially bounded translation.**  The budget inflation forced on any
translation of the numeral code into the length code exceeds every polynomial:
the two systems are extensionally identical yet cognitively incomparable at
polynomial resources.  This is the precise sense, promised by extension 4, in
which "expressive convenience" and genuine resource-bounded strength differ. -/
theorem no_polynomial_translation_bcode_to_lengthSystem
    (t : Translation (binary bcode) lengthSystem) (c k : ℕ) :
    ∃ b : ℕ, c * b ^ k + c < t.bound b := by
  obtain ⟨N, hN⟩ := nat_poly_lt_two_pow_succ c k
  refine ⟨N, ?_⟩
  have h1 := hN N le_rfl
  have h2 := bcode_to_lengthSystem_bound_ge t N
  omega

/-! ## Ordinal-ranked antichains of arbitrary size -/

/-- The theory proving exactly the single sentence `i`. -/
def singletonTool {ι : Type*} (i : ι) : FormalSystem ι := ⟨{i}⟩

/-- Distinct singleton theories are incomparable in proof strength. -/
theorem not_stronger_singletonTool {ι : Type*} (i j : ι) :
    ¬ Stronger (singletonTool i) (singletonTool j) := by
  rintro ⟨hsub, hne⟩
  have hj : j ∈ ({i} : Set ι) := hsub rfl
  have : j = i := hj
  exact hne (by rw [this])

/-- The singleton family is (vacuously) ordinal-ranked by the constant `0`. -/
theorem ordinalRanks_singletonTool (ι : Type*) :
    OrdinalRanks (fun i : ι => singletonTool i) (fun _ => (0 : Ordinal.{0})) := fun i j hij =>
  absurd hij (not_stronger_singletonTool j i)

/-- Hence the singleton family's strength order is well founded. -/
theorem wellFounded_singletonTool (ι : Type*) :
    WellFounded (fun i j : ι => Stronger (singletonTool j) (singletonTool i)) :=
  hierarchy_wellFounded_of_ordinalRanks _ _ (ordinalRanks_singletonTool ι)

/-- **Antichains of every finite size.**  For every `n` there is a family of `n`
pairwise distinct, pairwise incomparable theories that is ordinal-ranked and
hence well founded.  Well-foundedness of a hierarchy of mind tools therefore
never yields comparability, and the failure is not confined to small families:
it occurs at every cardinality. -/
theorem exists_ordinalRanked_antichain (n : ℕ) :
    ∃ (tools : Fin n → FormalSystem (Fin n)) (rank : Fin n → Ordinal.{0}),
      Function.Injective tools ∧
      OrdinalRanks tools rank ∧
      WellFounded (fun i j : Fin n => Stronger (tools j) (tools i)) ∧
      ∀ i j, ¬ Stronger (tools i) (tools j) := by
  refine ⟨fun i => singletonTool i, fun _ => 0, ?_, ordinalRanks_singletonTool _,
    wellFounded_singletonTool _, fun i j => not_stronger_singletonTool i j⟩
  intro i j hij
  have : ({i} : Set (Fin n)) = {j} := congrArg FormalSystem.provable hij
  have hi : i ∈ ({j} : Set (Fin n)) := this ▸ rfl
  exact hi

/-- The same phenomenon for an infinite index set: an infinite ordinal-ranked
antichain of theories. -/
theorem exists_infinite_ordinalRanked_antichain :
    ∃ (tools : ℕ → FormalSystem ℕ) (rank : ℕ → Ordinal.{0}),
      Function.Injective tools ∧
      OrdinalRanks tools rank ∧
      WellFounded (fun i j : ℕ => Stronger (tools j) (tools i)) ∧
      ∀ i j, ¬ Stronger (tools i) (tools j) := by
  refine ⟨fun i => singletonTool i, fun _ => 0, ?_, ordinalRanks_singletonTool _,
    wellFounded_singletonTool _, fun i j => not_stronger_singletonTool i j⟩
  intro i j hij
  have : ({i} : Set ℕ) = {j} := congrArg FormalSystem.provable hij
  have hi : i ∈ ({j} : Set ℕ) := this ▸ rfl
  exact hi

end Bounded
end MindTools