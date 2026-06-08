import Mathlib

/-!
# Tropical Curry–Howard: Canonical Normalization of Min-Plus Proofs

This module establishes a formal tropical proof calculus in which **cut elimination
is min-plus optimization** and **normalization computes the unique canonical least-cost
proof representative**.

## The Calculus

- **`TropProof`**: Syntax of tropical proof terms with `atom` (basic proofs of known cost),
  `cut` (sequential composition), `tmin` (nondeterministic choice / min), and `tplus`
  (parallel resource accumulation).

- **`cost`**: The tropical cost semantics in the min-plus semiring (ℕ, min, +).

- **`TropStep`**: One-step reduction combining:
  - *Distributive rules*: `cut`/`tplus` distribute over `tmin` (the algebraic engine of
    min-plus normalization),
  - *Idempotent collapse*: `tmin p p → p` (duplicate proof elimination),
  - *Computation rules*: `cut/tplus/tmin` of atoms evaluate to a single atom
    (cost computation at the leaves),
  - *Congruence closure*: reduction under any subterm context.

## Main Theorems

1. **Soundness** (`step_preserves_cost`): Every reduction step preserves tropical cost.
2. **Strong normalization** (`strongly_normalizing`): No infinite reduction sequence exists
   (via polynomial interpretation).
3. **Normal form characterization** (`normal_is_atom`): Every normal form is an atom —
   the fully evaluated cost certificate.
4. **Canonical normalization** (`reduces_to_normalize`): Every term reduces to
   `atom (cost p)`, the unique canonical normal form.
5. **Global confluence** (`tropical_confluence`): Any two reduction paths from a term
   can be extended to a common reduct.
6. **Uniqueness** (`normalize_unique`, `normalize_complete`): Normal forms are unique;
   the `normalize` function is a complete invariant of reduction equivalence.
7. **Optimality** (`normalize_canonical`): Among all convertible terms, the canonical
   normal form is the unique normal representative.

## Cross-Domain Significance

- **Proof theory**: Cut elimination = optimization in the min-plus semiring.
- **Dynamic programming**: Proof normalization = shortest-path computation.
- **Tropical geometry**: Normal forms = vertices of tropical proof polytopes.
- **Weighted type systems**: Cost-annotated Curry–Howard correspondence.
- **Certified optimization**: Normalization produces verified optimal cost certificates.

## Keywords

tropical logic, Curry–Howard correspondence, min-plus algebra, idempotent semiring,
cut elimination, confluence, strong normalization, canonical forms, shortest-path semantics,
dynamic programming, certified optimization, proof complexity, tropical geometry
-/

namespace TropicalCurryHowardCanonical

/-! ## Syntax -/

/-- Tropical proof terms over `Nat` costs.
- `atom n`: A basic proof/axiom of cost `n`.
- `cut p q`: Sequential composition (cost = sum). The proof-theoretic cut rule.
- `tmin p q`: Nondeterministic choice (cost = minimum). Idempotent branching.
- `tplus p q`: Parallel resource accumulation (cost = sum). -/
inductive TropProof where
  | atom : Nat → TropProof
  | cut : TropProof → TropProof → TropProof
  | tmin : TropProof → TropProof → TropProof
  | tplus : TropProof → TropProof → TropProof
deriving DecidableEq, Repr

namespace TropProof

/-! ## Semantics -/

/-- **Tropical cost semantics**: evaluates a proof term in the min-plus semiring (ℕ, min, +).
Sequential and parallel composition add costs; nondeterministic choice takes the minimum. -/
def cost : TropProof → Nat
  | .atom n => n
  | .cut p q => cost p + cost q
  | .tmin p q => min (cost p) (cost q)
  | .tplus p q => cost p + cost q

/-! ## Termination Measure -/

/-- Polynomial interpretation for proving strong normalization.
Maps `cut` and `tplus` to multiplication, `min` to addition + 1.
Each reduction rule strictly decreases this measure. -/
def interp : TropProof → Nat
  | .atom _ => 2
  | .cut p q => interp p * interp q
  | .tmin p q => interp p + interp q + 1
  | .tplus p q => interp p * interp q

/-! ## Reduction System -/

/-- **One-step tropical reduction**. This relation captures the complete normalization
dynamics of the tropical proof calculus.

**Distributive rules** push `cut`/`tplus` inside `tmin`, exposing choices for collapse.
**Idempotent collapse** (`min_idem`) eliminates duplicate proof branches.
**Computation rules** (`cut_atoms`, `tplus_atoms`, `tmin_atoms`) evaluate fully
reduced subterms into single atoms — the terminal computation step.
**Congruence rules** allow reduction inside any subterm context. -/
inductive TropStep : TropProof → TropProof → Prop where
  | cut_tmin_left (p q r : TropProof) :
      TropStep (.cut (.tmin p q) r) (.tmin (.cut p r) (.cut q r))
  | cut_tmin_right (p q r : TropProof) :
      TropStep (.cut p (.tmin q r)) (.tmin (.cut p q) (.cut p r))
  | tplus_tmin_left (p q r : TropProof) :
      TropStep (.tplus (.tmin p q) r) (.tmin (.tplus p r) (.tplus q r))
  | tplus_tmin_right (p q r : TropProof) :
      TropStep (.tplus p (.tmin q r)) (.tmin (.tplus p q) (.tplus p r))
  | min_idem (p : TropProof) :
      TropStep (.tmin p p) p
  | cut_atoms (a b : Nat) :
      TropStep (.cut (.atom a) (.atom b)) (.atom (a + b))
  | tplus_atoms (a b : Nat) :
      TropStep (.tplus (.atom a) (.atom b)) (.atom (a + b))
  | tmin_atoms (a b : Nat) :
      TropStep (.tmin (.atom a) (.atom b)) (.atom (min a b))
  | ctx_cut_left {p q : TropProof} (r : TropProof) :
      TropStep p q → TropStep (.cut p r) (.cut q r)
  | ctx_cut_right (p : TropProof) {q r : TropProof} :
      TropStep q r → TropStep (.cut p q) (.cut p r)
  | ctx_tmin_left {p q : TropProof} (r : TropProof) :
      TropStep p q → TropStep (.tmin p r) (.tmin q r)
  | ctx_tmin_right (p : TropProof) {q r : TropProof} :
      TropStep q r → TropStep (.tmin p q) (.tmin p r)
  | ctx_tplus_left {p q : TropProof} (r : TropProof) :
      TropStep p q → TropStep (.tplus p r) (.tplus q r)
  | ctx_tplus_right (p : TropProof) {q r : TropProof} :
      TropStep q r → TropStep (.tplus p q) (.tplus p r)

/-- **Primitive reduction steps** (without context closure). These are the root-level
algebraic transformations of the tropical calculus. -/
inductive PrimStep : TropProof → TropProof → Prop where
  | cut_tmin_left (p q r : TropProof) :
      PrimStep (.cut (.tmin p q) r) (.tmin (.cut p r) (.cut q r))
  | cut_tmin_right (p q r : TropProof) :
      PrimStep (.cut p (.tmin q r)) (.tmin (.cut p q) (.cut p r))
  | tplus_tmin_left (p q r : TropProof) :
      PrimStep (.tplus (.tmin p q) r) (.tmin (.tplus p r) (.tplus q r))
  | tplus_tmin_right (p q r : TropProof) :
      PrimStep (.tplus p (.tmin q r)) (.tmin (.tplus p q) (.tplus p r))
  | min_idem (p : TropProof) :
      PrimStep (.tmin p p) p
  | cut_atoms (a b : Nat) :
      PrimStep (.cut (.atom a) (.atom b)) (.atom (a + b))
  | tplus_atoms (a b : Nat) :
      PrimStep (.tplus (.atom a) (.atom b)) (.atom (a + b))
  | tmin_atoms (a b : Nat) :
      PrimStep (.tmin (.atom a) (.atom b)) (.atom (min a b))

/-- A term is in **normal form** when no reduction step applies.
In this calculus, normal forms are exactly the atoms (Theorem `normal_is_atom`). -/
def Normal (p : TropProof) : Prop := ¬∃ q, TropStep p q

/-- Two terms are **convertible** if they share a common reduct. -/
def Convertible (p q : TropProof) : Prop :=
  ∃ s, Relation.ReflTransGen TropStep p s ∧ Relation.ReflTransGen TropStep q s

/-- **Canonical normalizer**: evaluates cost and wraps as an atom.
This is the unique normal form of every term (Theorem `reduces_to_normalize`). -/
def normalize (p : TropProof) : TropProof := .atom (cost p)

/-! ## Section 1: Every Primitive Step is a Full Step -/

theorem primstep_subset_tropstep {p q : TropProof} (h : PrimStep p q) : TropStep p q := by
  cases h <;> constructor

/-! ## Section 2: Soundness — Reduction Preserves Tropical Cost -/

/-- **Soundness**: Every single reduction step preserves tropical cost.
This is the fundamental semantic invariant: normalization is cost-transparent.
Uses the min-plus distributivity law `a + min(b,c) = min(a+b, a+c)` and
the idempotence `min(a,a) = a`. -/
theorem step_preserves_cost {p q : TropProof} (h : TropStep p q) :
    cost q = cost p := by
  induction h <;> simp [cost, Nat.add_min_add_left, *]

/-- **Transitive soundness**: Any reduction sequence preserves cost. -/
theorem rtc_preserves_cost {p q : TropProof}
    (h : Relation.ReflTransGen TropStep p q) : cost q = cost p := by
  induction h with
  | refl => rfl
  | tail _ step ih => rw [step_preserves_cost step, ih]

/-! ## Section 3: Termination — Polynomial Interpretation -/

/-- The interpretation is always at least 2, ensuring multiplicative strict decrease. -/
theorem interp_ge_two (p : TropProof) : 2 ≤ interp p := by
  induction p with
  | atom _ => simp [interp]
  | cut p q ihp ihq => simp [interp]; nlinarith
  | tmin p q ihp ihq => simp [interp]; omega
  | tplus p q ihp ihq => simp [interp]; nlinarith

/-
**Strict decrease**: Every reduction step strictly decreases the polynomial
interpretation. This is the engine of strong normalization.
-/
theorem step_decreases_interp {p q : TropProof} (h : TropStep p q) :
    interp q < interp p := by
  -- Let's prove the strict decrease of the polynomial interpretation under each TropStep case.
  have h_cases : ∀ {p q : TropProof}, TropStep p q → q.interp < p.interp := by
    intros p q h;
    induction' h with p q h ih;
    all_goals norm_num [ TropProof.interp ];
    any_goals nlinarith [ show 2 ≤ TropProof.interp ‹_› from interp_ge_two _ ];
    · linarith [ show 2 ≤ TropProof.interp ih from interp_ge_two ih ];
    · rename_i p q r; nlinarith [ show 2 ≤ TropProof.interp p from interp_ge_two p, show 2 ≤ TropProof.interp q from interp_ge_two q, show 2 ≤ TropProof.interp r from interp_ge_two r ] ;
    · exact Nat.mul_lt_mul_of_pos_left ‹_› ( show 0 < _ from Nat.pos_of_ne_zero ( by { exact ne_of_gt ( show 0 < TropProof.interp _ from Nat.pos_of_ne_zero ( by { exact ne_of_gt ( show 0 < TropProof.interp _ from Nat.pos_of_ne_zero ( by { exact ne_of_gt ( show 0 < TropProof.interp _ from Nat.pos_of_ne_zero ( by { exact ne_of_gt ( show 0 < TropProof.interp _ from Nat.pos_of_ne_zero ( by { exact ne_of_gt ( show 0 < TropProof.interp _ from Nat.pos_of_ne_zero ( by { exact ne_of_gt ( show 0 < TropProof.interp _ from Nat.zero_lt_of_lt ( interp_ge_two _ ) ) } ) ) } ) ) } ) ) } ) ) } ) ) } ) );
    · exact Nat.mul_lt_mul_of_pos_left ‹_› ( show 0 < _ from Nat.pos_of_ne_zero ( by { exact ne_of_gt ( show 0 < TropProof.interp _ from Nat.pos_of_ne_zero ( by { exact ne_of_gt ( show 0 < TropProof.interp _ from Nat.pos_of_ne_zero ( by { exact ne_of_gt ( show 0 < TropProof.interp _ from Nat.pos_of_ne_zero ( by { exact ne_of_gt ( show 0 < TropProof.interp _ from Nat.pos_of_ne_zero ( by { exact ne_of_gt ( show 0 < TropProof.interp _ from Nat.pos_of_ne_zero ( by { exact ne_of_gt ( show 0 < TropProof.interp _ from Nat.zero_lt_of_lt ( interp_ge_two _ ) ) } ) ) } ) ) } ) ) } ) ) } ) ) } ) );
  exact h_cases h

/-
**Strong normalization**: The reduction relation is well-founded.
No infinite reduction sequence exists in the tropical proof calculus.
-/
theorem strongly_normalizing : WellFounded (fun a b => TropStep b a) := by
  have h_wf : WellFounded (fun a b : TropProof => interp a < interp b) :=
    InvImage.wf interp wellFounded_lt
  exact h_wf.mono fun a b h => step_decreases_interp h

/-! ## Section 4: Normal Form Characterization -/

/-
Atoms are always in normal form: no reduction rule has `atom n` as its LHS.
-/
theorem atom_normal (n : Nat) : Normal (.atom n) := by
  intro h
  obtain ⟨q, h_step⟩ := h
  cases h_step

/-- Subterm normality: if `cut p q` is normal, then `p` is normal. -/
theorem normal_sub_cut_left {p q : TropProof} (h : Normal (.cut p q)) : Normal p := by
  intro ⟨p', hp'⟩; exact h ⟨.cut p' q, .ctx_cut_left q hp'⟩

/-- Subterm normality: if `cut p q` is normal, then `q` is normal. -/
theorem normal_sub_cut_right {p q : TropProof} (h : Normal (.cut p q)) : Normal q := by
  intro ⟨q', hq'⟩; exact h ⟨.cut p q', .ctx_cut_right p hq'⟩

/-- Subterm normality: if `tmin p q` is normal, then `p` is normal. -/
theorem normal_sub_tmin_left {p q : TropProof} (h : Normal (.tmin p q)) : Normal p := by
  intro ⟨p', hp'⟩; exact h ⟨.tmin p' q, .ctx_tmin_left q hp'⟩

/-- Subterm normality: if `tmin p q` is normal, then `q` is normal. -/
theorem normal_sub_tmin_right {p q : TropProof} (h : Normal (.tmin p q)) : Normal q := by
  intro ⟨q', hq'⟩; exact h ⟨.tmin p q', .ctx_tmin_right p hq'⟩

/-- Subterm normality: if `tplus p q` is normal, then `p` is normal. -/
theorem normal_sub_tplus_left {p q : TropProof} (h : Normal (.tplus p q)) : Normal p := by
  intro ⟨p', hp'⟩; exact h ⟨.tplus p' q, .ctx_tplus_left q hp'⟩

/-- Subterm normality: if `tplus p q` is normal, then `q` is normal. -/
theorem normal_sub_tplus_right {p q : TropProof} (h : Normal (.tplus p q)) : Normal q := by
  intro ⟨q', hq'⟩; exact h ⟨.tplus p q', .ctx_tplus_right p hq'⟩

/-
**Normal form characterization**: Every normal form in the tropical calculus
is an atom. This is the key structural theorem — it says that the computation rules
(`cut_atoms`, `tplus_atoms`, `tmin_atoms`) together with distributivity and idempotence
are powerful enough to reduce every compound term.
-/
theorem normal_is_atom {p : TropProof} (h : Normal p) : ∃ n, p = .atom n := by
  induction' p;
  · use ‹_›;
  · rename_i p q hp hq;
    exact absurd ( hp ( normal_sub_cut_left h ) ) ( by rintro ⟨ n, rfl ⟩ ; exact absurd ( hq ( normal_sub_cut_right h ) ) ( by rintro ⟨ m, rfl ⟩ ; exact h ⟨ _, TropStep.cut_atoms n m ⟩ ) );
  · unfold TropProof.Normal at h;
    rename_i p q hp hq;
    by_cases hp' : Normal p <;> by_cases hq' : Normal q <;> simp_all +decide;
    · obtain ⟨ n, rfl ⟩ := hp; obtain ⟨ m, rfl ⟩ := hq; exact h _ ( TropStep.tmin_atoms _ _ ) ;
    · contrapose! h;
      obtain ⟨ x, hx ⟩ := not_forall.mp hq';
      exact ⟨ _, TropStep.ctx_tmin_right _ x.choose_spec ⟩;
    · contrapose! h;
      obtain ⟨ r, hr ⟩ := not_forall.mp hp';
      exact ⟨ _, TropStep.ctx_tmin_left _ r.choose_spec ⟩;
    · exact hp' fun ⟨ r, hr ⟩ => h _ <| TropProof.TropStep.ctx_tmin_left _ hr;
  · rename_i p q hp hq;
    exact absurd ( normal_sub_tplus_left h ) ( by rintro H; obtain ⟨ n, rfl ⟩ := hp H; obtain ⟨ m, rfl ⟩ := hq ( normal_sub_tplus_right h ) ; exact h ⟨ _, TropStep.tplus_atoms _ _ ⟩ )

/-- Normal forms cannot be idempotent min-pairs. -/
theorem normal_no_min_self {p : TropProof} (h : Normal p) (q : TropProof) :
    p ≠ .tmin q q := by
  intro heq; subst heq; exact h ⟨q, .min_idem q⟩

/-! ## Section 5: Congruence Lifting for ReflTransGen -/

/-- Lifting multi-step reduction through left `cut` context. -/
theorem rtc_ctx_cut_left (q : TropProof) {p p' : TropProof}
    (h : Relation.ReflTransGen TropStep p p') :
    Relation.ReflTransGen TropStep (.cut p q) (.cut p' q) := by
  induction h with
  | refl => exact .refl
  | tail _ step ih => exact ih.tail (.ctx_cut_left q step)

/-- Lifting multi-step reduction through right `cut` context. -/
theorem rtc_ctx_cut_right (p : TropProof) {q q' : TropProof}
    (h : Relation.ReflTransGen TropStep q q') :
    Relation.ReflTransGen TropStep (.cut p q) (.cut p q') := by
  induction h with
  | refl => exact .refl
  | tail _ step ih => exact ih.tail (.ctx_cut_right p step)

/-- Lifting multi-step reduction through left `tmin` context. -/
theorem rtc_ctx_tmin_left (q : TropProof) {p p' : TropProof}
    (h : Relation.ReflTransGen TropStep p p') :
    Relation.ReflTransGen TropStep (.tmin p q) (.tmin p' q) := by
  induction h with
  | refl => exact .refl
  | tail _ step ih => exact ih.tail (.ctx_tmin_left q step)

/-- Lifting multi-step reduction through right `tmin` context. -/
theorem rtc_ctx_tmin_right (p : TropProof) {q q' : TropProof}
    (h : Relation.ReflTransGen TropStep q q') :
    Relation.ReflTransGen TropStep (.tmin p q) (.tmin p q') := by
  induction h with
  | refl => exact .refl
  | tail _ step ih => exact ih.tail (.ctx_tmin_right p step)

/-- Lifting multi-step reduction through left `tplus` context. -/
theorem rtc_ctx_tplus_left (q : TropProof) {p p' : TropProof}
    (h : Relation.ReflTransGen TropStep p p') :
    Relation.ReflTransGen TropStep (.tplus p q) (.tplus p' q) := by
  induction h with
  | refl => exact .refl
  | tail _ step ih => exact ih.tail (.ctx_tplus_left q step)

/-- Lifting multi-step reduction through right `tplus` context. -/
theorem rtc_ctx_tplus_right (p : TropProof) {q q' : TropProof}
    (h : Relation.ReflTransGen TropStep q q') :
    Relation.ReflTransGen TropStep (.tplus p q) (.tplus p q') := by
  induction h with
  | refl => exact .refl
  | tail _ step ih => exact ih.tail (.ctx_tplus_right p step)

/-! ## Section 6: Canonical Normalization -/

/-
**Every term reduces to its canonical normal form**: `p →* atom (cost p)`.
This is the central computational theorem — it says normalization always terminates
at the unique atom representing the term's tropical cost.

The proof proceeds by structural induction:
- Atoms are already normal.
- For `cut p q`: reduce `p →* atom (cost p)` and `q →* atom (cost q)` by IH,
  lift through context, then apply `cut_atoms`.
- Similarly for `tmin` (using `tmin_atoms`) and `tplus` (using `tplus_atoms`).
-/
theorem reduces_to_normalize (p : TropProof) :
    Relation.ReflTransGen TropStep p (normalize p) := by
  induction' p using TropProof.recOn with p hp q hq;
  · rfl;
  · -- By definition of normalize, we know that normalize (cut p q) = atom (cost p + cost q). Therefore, we can conclude that hp.cut q reduces to atom (cost hp + cost q).
    have h_cut : Relation.ReflTransGen TropStep (hp.cut q) (hp.normalize.cut q.normalize) := by
      exact Relation.ReflTransGen.trans ( rtc_ctx_cut_left _ hq ) ( rtc_ctx_cut_right _ ‹_› );
    convert h_cut.tail _ using 1;
    convert TropStep.cut_atoms _ _ using 1;
  · rename_i p q hp hq;
    -- By the induction hypothesis, we can reduce `p` and `q` to their normalized forms.
    have h_tmin : Relation.ReflTransGen TropStep (.tmin p q) (.tmin (normalize p) (normalize q)) := by
      exact rtc_ctx_tmin_left _ hp |> Relation.ReflTransGen.trans <| rtc_ctx_tmin_right _ hq;
    refine' h_tmin.tail _;
    convert TropStep.tmin_atoms _ _ using 1;
  · rename_i p q hp hq;
    have h_tplus : Relation.ReflTransGen TropStep (TropProof.tplus p q) (TropProof.tplus (TropProof.atom (TropProof.cost p)) (TropProof.atom (TropProof.cost q))) := by
      exact TropProof.rtc_ctx_tplus_left _ hp |> Relation.ReflTransGen.trans <| TropProof.rtc_ctx_tplus_right _ hq;
    exact h_tplus.tail ( by exact TropStep.tplus_atoms _ _ )

/-! ## Section 7: Normalizer Properties -/

/-- The canonical normal form is indeed normal (atoms have no reductions). -/
theorem normalize_normal (p : TropProof) : Normal (normalize p) :=
  atom_normal (cost p)

/-- Normalization preserves cost (by definition). -/
theorem normalize_cost (p : TropProof) : cost (normalize p) = cost p := by
  simp [normalize, cost]

/-! ## Section 8: Confluence -/

/-
**Global confluence (Church–Rosser property)**: Any two reduction sequences
from a common source can be extended to meet at a common target.

The proof exploits the semantic characterization:
- Every term `p` reduces to `atom (cost p)` (by `reduces_to_normalize`).
- Reduction preserves cost (by `rtc_preserves_cost`).
- Therefore `q →* atom (cost q) = atom (cost p)` and `r →* atom (cost r) = atom (cost p)`.

This is the tropical proof-theoretic analogue of the fact that shortest-path
computation is order-independent: all evaluation strategies yield the same optimal cost.
-/
theorem tropical_confluence {p q r : TropProof}
    (hpq : Relation.ReflTransGen TropStep p q)
    (hpr : Relation.ReflTransGen TropStep p r) :
    ∃ s, Relation.ReflTransGen TropStep q s ∧ Relation.ReflTransGen TropStep r s := by
  -- By reduces_to_normalize, both q and r reduce to atom (cost q) and atom (cost r) respectively.
  have hq : Relation.ReflTransGen TropStep q (normalize q) := reduces_to_normalize q
  have hr : Relation.ReflTransGen TropStep r (normalize r) := reduces_to_normalize r
  -- Since cost q = cost p and cost r = cost p, we have normalize q = normalize p and normalize r = normalize p.
  have hq_cost : cost q = cost p := rtc_preserves_cost hpq
  have hr_cost : cost r = cost p := rtc_preserves_cost hpr
  have hq_normalize : normalize q = normalize p := by
    unfold TropProof.normalize; aesop;
  have hr_normalize : normalize r = normalize p := by
    exact congr_arg ( fun x => TropProof.atom x ) hr_cost;
  grind +locals

/-! ## Section 9: Uniqueness and Canonicality -/

/-
A normal form is not reducible, so the only reflexive-transitive
sequence from it is the trivial one.
-/
theorem normal_rtc_eq {p q : TropProof} (hp : Normal p)
    (h : Relation.ReflTransGen TropStep p q) : p = q := by
  induction h;
  · rfl;
  · exact False.elim <| hp ⟨ _, by subst_vars; assumption ⟩

/-- **Normal form uniqueness**: If two normal forms are connected by reduction,
they must be identical. This is a consequence of confluence and the fact that
normal forms cannot be further reduced. -/
theorem normalize_unique {p q : TropProof}
    (hp : Normal p) (_hq : Normal q)
    (h : Relation.ReflTransGen TropStep p q) : p = q :=
  normal_rtc_eq hp h

/-- **Completeness of the normalizer**: If `p` reduces to `q` (in any number of steps),
then `normalize p = normalize q`. The normalizer is a complete invariant of
the reduction equivalence relation. -/
theorem normalize_complete (p q : TropProof)
    (h : Relation.ReflTransGen TropStep p q) : normalize p = normalize q := by
  simp [normalize, rtc_preserves_cost h]

/-
**Canonicality**: If `p` and `q` are convertible and `q` is already normal,
then `normalize p = q`. This is the crown jewel — it says the normalizer computes
the unique normal representative of any equivalence class.
-/
theorem normalize_canonical {p q : TropProof}
    (h : Convertible p q) (hq : Normal q) : normalize p = q := by
  -- By definition of convertibility, there exists a term $s$ such that $p$ reduces to $s$ and $q$ reduces to $s$.
  obtain ⟨s, hs⟩ : ∃ s, Relation.ReflTransGen TropStep p s ∧ Relation.ReflTransGen TropStep q s := by
    grind +locals;
  -- Since $q$ is normal and $q \rightarrow^* s$, by the property of normal forms, we have $q = s$.
  have hq_eq_s : q = s := by
    exact normal_rtc_eq hq hs.2;
  have hp_eq_s : p.normalize = s := by
    have h_cost : cost p = cost s := by
      exact hs.1 |> fun h => rtc_preserves_cost h ▸ rfl
    have := normal_is_atom hq; aesop;
  exact hp_eq_s.trans hq_eq_s.symm

/-! ## Section 10: Optimality -/

/-
**Cost optimality**: The normalized form has cost equal to (hence ≤) any
convertible term. Since reduction preserves cost, all convertible terms share
the same cost — normalization certifies this optimal value.
-/
theorem normalize_is_optimal (p : TropProof) :
    ∀ q, Convertible p q → cost (normalize p) ≤ cost q := by
  intros q hq;
  -- Since q is also divisible by p, by the previous result we have q.cost = cost (normalize q).
  have hq_cost : q.cost = p.cost := by
    obtain ⟨ s, hs₁, hs₂ ⟩ := hq;
    have h_cost_eq : cost s = cost p ∧ cost s = cost q := by
      exact ⟨ rtc_preserves_cost hs₁, rtc_preserves_cost hs₂ ⟩;
    grind +splitImp;
  grind +suggestions

/-- **Semantic uniqueness**: Any two normal forms of the same term have
identical tropical cost. -/
theorem normal_forms_eval_eq {t u v : TropProof}
    (htu : Relation.ReflTransGen TropStep t u) (_hu : Normal u)
    (htv : Relation.ReflTransGen TropStep t v) (_hv : Normal v) :
    cost u = cost v := by
  rw [rtc_preserves_cost htu, rtc_preserves_cost htv]

/-! ## Section 11: Normal Form Existence -/

/-- Every term has a normal form reachable by reduction. -/
theorem normal_form_exists (t : TropProof) :
    ∃ u, Relation.ReflTransGen TropStep t u ∧ Normal u :=
  ⟨normalize t, reduces_to_normalize t, normalize_normal t⟩

/-! ## Section 12: The Flagship Theorem -/

/-- **THE TROPICAL CURRY–HOWARD CANONICAL NORMALIZATION THEOREM**

In the tropical proof calculus:
1. Every proof term reduces to a unique canonical normal form `atom (cost p)`.
2. The canonical form is the unique atom whose value equals the min-plus cost.
3. Normalization is semantics-preserving, confluent, and strongly normalizing.
4. Proof identity is computed by tropical optimization and idempotent collapse.

This theorem packages the full result: `normalize` is a certified, canonical,
cost-preserving, confluent normalizer for the tropical proof calculus. -/
theorem tropical_curry_howard_canonical (p : TropProof) :
    Relation.ReflTransGen TropStep p (normalize p) ∧
    Normal (normalize p) ∧
    cost (normalize p) = cost p ∧
    (∀ q, Relation.ReflTransGen TropStep p q → Normal q → normalize p = q) := by
  refine ⟨reduces_to_normalize p, normalize_normal p, normalize_cost p, ?_⟩
  intro q hpq hq
  have : Convertible p q := ⟨q, hpq, .refl⟩
  exact normalize_canonical this hq

end TropProof
end TropicalCurryHowardCanonical