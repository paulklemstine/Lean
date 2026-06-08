import Mathlib

/-!
# Effective Finite-Quotient Injectivity for Bounded Berggren Words

## Overview

We prove that the Berggren evaluation map remains injective after reduction modulo `q`,
provided `q` exceeds an explicit threshold determined by the word-length bound and the
maximum entry growth of the Berggren generators. This is an **effective residual finiteness
theorem** for the Berggren semigroup.

## Main Results

* `tripleSupNorm_actGen_le` — each Berggren generator multiplies the sup-norm by at most 7
* `tripleSupNorm_evalTriple_le` — evaluation of length-n word has sup-norm ≤ 5 * 7^n
* `reduceTripleMod_eq_of_small_difference` — small congruent triples are equal
* `berggren_reduce_injective_on_length_le` — reduction mod `q` is injective on bounded words
* `bounded_key_recovery_exists` — a canonical decoder exists under the injectivity threshold
* `spb_dlog_reduces_to_berggren_word_recovery` — word recovery solves the encoded DLP

## References

* Berggren, B. (1934). "Pytagoreiska trianglar"
* Barning, F. J. M. (1963). "Over pythagorese en bijna-pythagorese driehoeken"
-/

open scoped Classical

/-! ## Berggren Generators and Words

We reproduce the essential definitions from the freeness development. -/

/-- The three Berggren generators. -/
inductive BergGen' : Type
  | A  -- Left branch (B₁)
  | B  -- Middle branch (B₂)
  | C  -- Right branch (B₃)
  deriving DecidableEq, Repr

/-- A Berggren word is a list of generators. -/
abbrev BergWord' := List BergGen'

/-- Action of a single Berggren generator on a triple `(a, b, c)`. -/
def actGen' (g : BergGen') (t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  match g, t with
  | .A, (a, b, c) => (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
  | .B, (a, b, c) => (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
  | .C, (a, b, c) => (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

/-- The root of the Berggren tree: (3, 4, 5). -/
def rootTriple' : ℤ × ℤ × ℤ := (3, 4, 5)

/-- Evaluate a Berggren word starting from the root. -/
def evalTriple' : BergWord' → ℤ × ℤ × ℤ
  | [] => rootTriple'
  | g :: rest => actGen' g (evalTriple' rest)

/-- A triple is *good* if it has positive coordinates and a² + b² = c². -/
def GoodTriple' (t : ℤ × ℤ × ℤ) : Prop :=
  0 < t.1 ∧ 0 < t.2.1 ∧ 0 < t.2.2 ∧ t.1 ^ 2 + t.2.1 ^ 2 = t.2.2 ^ 2

/-- Each generator is injective on triples. -/
theorem actGen'_injective (g : BergGen') : Function.Injective (actGen' g) := by
  intro ⟨a₁, b₁, c₁⟩ ⟨a₂, b₂, c₂⟩ h
  cases g <;> simp only [actGen', Prod.mk.injEq] at h <;> obtain ⟨h1, h2, h3⟩ := h <;>
    exact Prod.ext (by linarith) (Prod.ext (by linarith) (by linarith))

/-- The root is a good triple. -/
theorem root_good' : GoodTriple' rootTriple' := by
  refine ⟨by norm_num [rootTriple'], by norm_num [rootTriple'],
    by norm_num [rootTriple'], by norm_num [rootTriple']⟩

/-- Generators preserve good triples. -/
theorem actGen'_preserves_good (g : BergGen') {t : ℤ × ℤ × ℤ} (ht : GoodTriple' t) :
    GoodTriple' (actGen' g t) := by
  obtain ⟨ht1, ht2, ht3, ht4⟩ := ht
  rcases g with _ | _ | _
  · exact ⟨by unfold actGen'; nlinarith, by unfold actGen'; nlinarith,
           by unfold actGen'; nlinarith, by unfold actGen'; nlinarith⟩
  · exact ⟨by unfold actGen'; linarith, by unfold actGen'; linarith,
           by unfold actGen'; linarith, by unfold actGen'; nlinarith⟩
  · exact ⟨by unfold actGen'; nlinarith, by unfold actGen'; nlinarith,
           by unfold actGen'; nlinarith, by unfold actGen'; linarith⟩

/-- Every word evaluates to a good triple. -/
theorem evalTriple'_good (w : BergWord') : GoodTriple' (evalTriple' w) := by
  induction w with
  | nil => exact root_good'
  | cons g rest ih => exact actGen'_preserves_good g ih

/-- The hypotenuse of a good triple is at least 5. -/
theorem hyp_ge_five' {t : ℤ × ℤ × ℤ} (ht : GoodTriple' t) : 5 ≤ t.2.2 := by
  obtain ⟨ha, hb, hc, hpyth⟩ := ht
  by_contra h
  push_neg at h
  have : t.2.2 ≤ 4 := by omega
  have : t.1 ≤ 4 := by nlinarith [sq_nonneg t.2.1]
  have : t.2.1 ≤ 4 := by nlinarith [sq_nonneg t.1]
  interval_cases t.1 <;> interval_cases t.2.1 <;> interval_cases t.2.2 <;> simp_all

/-- Hypotenuse strictly increases under generators. -/
theorem hyp_increases' (g : BergGen') {t : ℤ × ℤ × ℤ} (ht : GoodTriple' t) :
    t.2.2 < (actGen' g t).2.2 := by
  obtain ⟨ha, hb, hc, _⟩ := ht
  cases g <;> simp [actGen'] <;> nlinarith [sq_nonneg (t.1 - t.2.1)]

/-- The root is never in the image of a generator applied to a good triple. -/
theorem actGen'_ne_root (g : BergGen') {t : ℤ × ℤ × ℤ} (ht : GoodTriple' t) :
    actGen' g t ≠ rootTriple' := by
  intro h
  have h1 := hyp_increases' g ht
  have h2 : (actGen' g t).2.2 = 5 := by rw [h]; rfl
  have h3 := hyp_ge_five' ht
  linarith

/-- Discriminant functions for unique parent determination. -/
def discX' (t : ℤ × ℤ × ℤ) : ℤ := t.1 + 2 * t.2.1 - 2 * t.2.2
def discY' (t : ℤ × ℤ × ℤ) : ℤ := 2 * t.1 + t.2.1 - 2 * t.2.2

/-- Generators are uniquely determined by their output on good triples. -/
theorem actGen'_generator_determined {g₁ g₂ : BergGen'} {p₁ p₂ : ℤ × ℤ × ℤ}
    (hp₁ : GoodTriple' p₁) (hp₂ : GoodTriple' p₂)
    (h : actGen' g₁ p₁ = actGen' g₂ p₂) : g₁ = g₂ := by
  obtain ⟨ha₁, hb₁, _, _⟩ := hp₁
  obtain ⟨ha₂, hb₂, _, _⟩ := hp₂
  have hdx : discX' (actGen' g₁ p₁) = discX' (actGen' g₂ p₂) := by rw [h]
  have hdy : discY' (actGen' g₁ p₁) = discY' (actGen' g₂ p₂) := by rw [h]
  obtain ⟨a₁, b₁, c₁⟩ := p₁
  obtain ⟨a₂, b₂, c₂⟩ := p₂
  simp only [actGen', discX', discY'] at hdx hdy
  cases g₁ <;> cases g₂ <;> simp_all <;> linarith

/-- **Berggren evaluation is injective** (freeness). -/
theorem berggren_eval_injective' : Function.Injective evalTriple' := by
  intro w₁
  induction w₁ with
  | nil =>
    intro w₂ h
    match w₂ with
    | [] => rfl
    | g :: rest =>
      exfalso
      exact actGen'_ne_root g (evalTriple'_good rest) h.symm
  | cons g₁ rest₁ ih =>
    intro w₂ h
    match w₂ with
    | [] =>
      exfalso
      exact actGen'_ne_root g₁ (evalTriple'_good rest₁) h
    | g₂ :: rest₂ =>
      simp only [evalTriple'] at h
      have hg := actGen'_generator_determined (evalTriple'_good rest₁) (evalTriple'_good rest₂) h
      subst hg
      congr 1
      exact ih (actGen'_injective g₁ h)

/-! ## Sup-Norm on Triples -/

/-- The sup-norm of an integer triple: the maximum absolute value of its entries. -/
def tripleSupNorm (t : ℤ × ℤ × ℤ) : ℕ :=
  max (Int.natAbs t.1) (max (Int.natAbs t.2.1) (Int.natAbs t.2.2))

/-- Each component's absolute value is bounded by the sup-norm. -/
theorem natAbs_fst_le_tsn (t : ℤ × ℤ × ℤ) :
    Int.natAbs t.1 ≤ tripleSupNorm t :=
  le_max_left _ _

theorem natAbs_snd_fst_le_tsn (t : ℤ × ℤ × ℤ) :
    Int.natAbs t.2.1 ≤ tripleSupNorm t :=
  le_trans (le_max_left _ _) (le_max_right _ _)

theorem natAbs_snd_snd_le_tsn (t : ℤ × ℤ × ℤ) :
    Int.natAbs t.2.2 ≤ tripleSupNorm t :=
  le_trans (le_max_right _ _) (le_max_right _ _)

/-! ## Entry-Growth Bound for Berggren Generators -/

/-
Each Berggren generator multiplies the sup-norm by at most 7.
-/
theorem tripleSupNorm_actGen_le (g : BergGen') (t : ℤ × ℤ × ℤ) :
    tripleSupNorm (actGen' g t) ≤ 7 * tripleSupNorm t := by
  obtain ⟨a, b, c⟩ := t;
  unfold tripleSupNorm; rcases g with ( _ | _ | _ ) <;> simp +decide [ actGen' ];
  · omega;
  · omega;
  · omega

/-- The root triple (3,4,5) has sup-norm 5. -/
theorem tripleSupNorm_rootTriple : tripleSupNorm rootTriple' = 5 := by
  native_decide

/-
Evaluation of a word of length `n` has sup-norm ≤ 5 * 7^n.
-/
theorem tripleSupNorm_evalTriple_le (w : BergWord') :
    tripleSupNorm (evalTriple' w) ≤ 5 * 7 ^ w.length := by
  induction w <;> simp_all +decide [ pow_succ' ];
  -- Apply the bound on the sup-norm of a single generator to the induction hypothesis.
  have := tripleSupNorm_actGen_le ‹_› (evalTriple' ‹_›); linarith!;

/-! ## Difference Bound -/

/-- The difference triple of two triples. -/
def tripleDiff (s t : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (s.1 - t.1, s.2.1 - t.2.1, s.2.2 - t.2.2)

/-
Sup-norm of a triple difference is bounded by sum of sup-norms.
-/
theorem tripleSupNorm_diff_le (s t : ℤ × ℤ × ℤ) :
    tripleSupNorm (tripleDiff s t) ≤ tripleSupNorm s + tripleSupNorm t := by
  unfold tripleSupNorm;
  simp +zetaDelta at *;
  refine' ⟨ _, _, _ ⟩;
  · exact le_trans ( Int.natAbs_sub_le _ _ ) ( add_le_add ( le_max_left _ _ ) ( le_max_left _ _ ) );
  · exact le_trans ( Int.natAbs_sub_le _ _ ) ( add_le_add ( by aesop ) ( by aesop ) );
  · exact le_trans ( Int.natAbs_sub_le _ _ ) ( add_le_add ( by aesop ) ( by aesop ) )

/-
Difference of two evaluations of bounded-length words has bounded sup-norm.
-/
theorem tripleSupNorm_evalTriple_diff_le {L : ℕ} (u v : BergWord')
    (hu : u.length ≤ L) (hv : v.length ≤ L) :
    tripleSupNorm (tripleDiff (evalTriple' u) (evalTriple' v)) ≤ 10 * 7 ^ L := by
  refine le_trans ( tripleSupNorm_diff_le _ _ ) ?_;
  exact le_trans ( add_le_add ( tripleSupNorm_evalTriple_le u ) ( tripleSupNorm_evalTriple_le v ) ) ( by linarith [ pow_le_pow_right₀ ( by decide : 1 ≤ 7 ) hu, pow_le_pow_right₀ ( by decide : 1 ≤ 7 ) hv ] )

/-! ## Reduction Modulo q -/

/-- Entrywise reduction of an integer triple modulo `q`. -/
def reduceTripleMod (q : ℕ) (t : ℤ × ℤ × ℤ) : ZMod q × ZMod q × ZMod q :=
  ((t.1 : ZMod q), (t.2.1 : ZMod q), (t.2.2 : ZMod q))

/-
Key arithmetic lemma: if `q ∣ z` and `|z| < q`, then `z = 0`.
-/
theorem int_eq_zero_of_dvd_of_natAbs_lt
    {z : ℤ} {q : ℕ} (_hq : 0 < q)
    (hdvd : (q : ℤ) ∣ z) (hsmall : Int.natAbs z < q) : z = 0 := by
  exact Int.eq_zero_of_dvd_of_natAbs_lt_natAbs hdvd hsmall

/-
If two triples agree mod `q`, their entrywise differences are divisible by `q`.
-/
theorem reduceTripleMod_eq_imp_dvd
    {q : ℕ} (_hq : 0 < q)
    {s t : ℤ × ℤ × ℤ}
    (h : reduceTripleMod q s = reduceTripleMod q t) :
    (q : ℤ) ∣ (s.1 - t.1) ∧ (q : ℤ) ∣ (s.2.1 - t.2.1) ∧ (q : ℤ) ∣ (s.2.2 - t.2.2) := by
  unfold reduceTripleMod at h; simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ] ;

/-
**Small-difference separation lemma**: if two triples agree mod `q` and
their entrywise difference has sup-norm < `q`, then they are equal.
-/
theorem reduceTripleMod_eq_of_small_difference
    {q : ℕ} (hq : 0 < q)
    {s t : ℤ × ℤ × ℤ}
    (hmod : reduceTripleMod q s = reduceTripleMod q t)
    (hsmall : tripleSupNorm (tripleDiff s t) < q) :
    s = t := by
  have h_eq : s.1 - t.1 = 0 ∧ s.2.1 - t.2.1 = 0 ∧ s.2.2 - t.2.2 = 0 := by
    exact ⟨ int_eq_zero_of_dvd_of_natAbs_lt hq ( reduceTripleMod_eq_imp_dvd hq hmod |>.1 ) ( by simpa using lt_of_le_of_lt ( natAbs_fst_le_tsn _ ) hsmall ), int_eq_zero_of_dvd_of_natAbs_lt hq ( reduceTripleMod_eq_imp_dvd hq hmod |>.2.1 ) ( by simpa using lt_of_le_of_lt ( natAbs_snd_fst_le_tsn _ ) hsmall ), int_eq_zero_of_dvd_of_natAbs_lt hq ( reduceTripleMod_eq_imp_dvd hq hmod |>.2.2 ) ( by simpa using lt_of_le_of_lt ( natAbs_snd_snd_le_tsn _ ) hsmall ) ⟩;
  exact Prod.ext ( sub_eq_zero.mp h_eq.1 ) ( Prod.ext ( sub_eq_zero.mp h_eq.2.1 ) ( sub_eq_zero.mp h_eq.2.2 ) )

/-! ## Main Injectivity Theorem -/

/-
**Effective injectivity modulo large q**: Berggren evaluation modulo `q` is
injective on words of length ≤ `L`, provided `q > 10 * 7^L`.
-/
theorem berggren_reduce_injective_on_length_le
    (L q : ℕ) (hq : 0 < q) (hsep : 10 * 7 ^ L < q)
    {u v : BergWord'}
    (hu : u.length ≤ L) (hv : v.length ≤ L)
    (hmod : reduceTripleMod q (evalTriple' u) = reduceTripleMod q (evalTriple' v)) :
    u = v := by
  apply berggren_eval_injective';
  exact reduceTripleMod_eq_of_small_difference hq hmod <| lt_of_le_of_lt ( tripleSupNorm_evalTriple_diff_le u v hu hv ) hsep

/-! ## Bounded Words and Injectivity -/

/-- The type of Berggren words of length ≤ L. -/
def BoundedBergWord' (L : ℕ) := {w : BergWord' // w.length ≤ L}

/-
Injectivity of the reduction map on the bounded keyspace.
-/
theorem berggren_reduce_injective_bounded
    (L q : ℕ) (hq : 0 < q) (hsep : 10 * 7 ^ L < q) :
    Function.Injective (fun w : BoundedBergWord' L =>
      reduceTripleMod q (evalTriple' w.1)) := by
  exact fun x y h => Subtype.ext <| berggren_reduce_injective_on_length_le L q hq hsep x.2 y.2 h

/-! ## Cryptographic Definitions -/

/-- The public-key type: a reduced triple modulo `q`. -/
def PubKey' (q : ℕ) := ZMod q × ZMod q × ZMod q

/-- The SPB public-key map: evaluate a Berggren word and reduce mod `q`. -/
def spbPublicMap' (q : ℕ) (w : BergWord') : PubKey' q :=
  reduceTripleMod q (evalTriple' w)

/-- A key-recovery adversary on bounded words. -/
def RecoversBoundedKeys' (L q : ℕ)
    (A : PubKey' q → Option (BoundedBergWord' L)) : Prop :=
  ∀ w : BoundedBergWord' L, A (spbPublicMap' q w.1) = some w

/-- Canonical decoder: finds the unique bounded word mapping to the given public key. -/
noncomputable def berggrenDecode (L q : ℕ) (pk : PubKey' q) :
    Option (BoundedBergWord' L) :=
  if h : ∃ w : BoundedBergWord' L, spbPublicMap' q w.1 = pk then
    some h.choose
  else
    none

/-
The canonical decoder is correct under the injectivity threshold.
-/
theorem berggrenDecode_correct
    (L q : ℕ) (hq : 0 < q) (hsep : 10 * 7 ^ L < q)
    (w : BoundedBergWord' L) :
    berggrenDecode L q (spbPublicMap' q w.1) = some w := by
  unfold berggrenDecode;
  split_ifs with h;
  · exact Option.some_inj.mpr ( berggren_reduce_injective_bounded L q hq hsep h.choose_spec );
  · exact h ⟨ w, rfl ⟩

/-! ## Key Recovery Existence and Uniqueness -/

/-
Under the injectivity threshold, a correct key-recovery algorithm exists.
-/
theorem bounded_key_recovery_exists
    (L q : ℕ) (hq : 0 < q) (hsep : 10 * 7 ^ L < q) :
    ∃ A : PubKey' q → Option (BoundedBergWord' L),
      RecoversBoundedKeys' L q A := by
  exact ⟨ _, fun w => berggrenDecode_correct L q hq hsep w ⟩

/-
Any correct bounded key-recovery agrees with the canonical decoder.
-/
theorem any_bounded_inverter_agrees
    (L q : ℕ) (hq : 0 < q) (hsep : 10 * 7 ^ L < q)
    {A : PubKey' q → Option (BoundedBergWord' L)}
    (hA : RecoversBoundedKeys' L q A) :
    ∀ w : BoundedBergWord' L,
      A (spbPublicMap' q w.1) = berggrenDecode L q (spbPublicMap' q w.1) := by
  intro w;
  rw [ berggrenDecode_correct L q hq hsep w, hA ]

/-! ## Hardness Transfer / Discrete-Log Reduction -/

/-
Recovering Berggren words solves the encoded discrete-log problem.
-/
theorem spb_dlog_reduces_to_berggren_word_recovery
    (L q : ℕ) (_hq : 0 < q) (_hsep : 10 * 7 ^ L < q)
    (encode : BoundedBergWord' L → ℕ)
    (_hencode_inj : Function.Injective encode)
    (spbPublicElem : ℕ → PubKey' q)
    (hpub : ∀ w : BoundedBergWord' L, spbPublicElem (encode w) = spbPublicMap' q w.1) :
    ∀ A : PubKey' q → Option (BoundedBergWord' L),
      RecoversBoundedKeys' L q A →
      ∃ B : PubKey' q → Option ℕ,
        ∀ w : BoundedBergWord' L,
          B (spbPublicElem (encode w)) = some (encode w) := by
  -- Define B as the composition of A and encode.
  intro A hA
  use fun pk => (A pk).map encode;
  aesop