import Logic.LambdaCalculus.Syntax

/-!
# The Church–Rosser theorem for the untyped λ-calculus

We prove confluence (the Church–Rosser property) of β-reduction using the
Tait/Martin-Löf **parallel reduction** `Par` together with Takahashi's
**complete development** `cd`.

## Strategy

1. `Par` reduces several redexes in one step; it sits between `Beta` and
   `BetaStar`: `Beta ⊆ Par ⊆ BetaStar`, so their reflexive–transitive closures
   coincide.
2. `cd t` is Takahashi's maximal one-step development of `t`.
3. **Triangle property** (`par_triangle`): if `t ⇒ u` then `u ⇒ cd t`.
4. The triangle gives the **diamond property** of `Par` immediately
   (`par_diamond`): the common reduct of any fork is `cd` of the source.
5. The diamond property lifts to the reflexive–transitive closure via
   `Relation.church_rosser`, yielding `church_rosser_beta`.

-- !-- Lab Notes -- !--
Hypothesis (H1): β-reduction is confluent, and the cleanest route is parallel
reduction with a *function* `cd` realising the diamond (Takahashi's triangle),
rather than the brittle "diamond by hand" argument.
Experiment: `Par` is defined with reflexive variable/structural rules plus a
β-rule that contracts simultaneously; `cd` is defined by structural recursion
with the redex case `app (lam t) u ↦ subst0 (cd u) (cd t)`.
Analysis: the triangle `Par t u → Par u (cd t)` is the load-bearing lemma; it
needs (a) `Par` to respect `lift` and `subst` (proved via the substitution
algebra in `Syntax.lean`), and (b) inversion of `Par` on `lam`/`app` heads.
Critique: the diamond hypothesis demanded by `Relation.church_rosser` is the
*weak* one (`ReflGen`/`ReflTransGen`); since `Par` is reflexive the full diamond
trivially supplies it.
-- !-- End Lab Notes -- !--
-/

namespace LambdaCalculus

open Lam

/-- **Parallel (Tait–Martin-Löf) reduction**: contracts a set of redexes
simultaneously in one step. -/
inductive Par : Lam → Lam → Prop
  | var (n : ℕ) : Par (var n) (var n)
  | lam {t t' : Lam} : Par t t' → Par (lam t) (lam t')
  | app {a a' b b' : Lam} : Par a a' → Par b b' → Par (app a b) (app a' b')
  | beta {t t' u u' : Lam} : Par t t' → Par u u' →
      Par (app (lam t) u) (subst0 u' t')

/-
Parallel reduction is reflexive.
-/
theorem par_refl (t : Lam) : Par t t := by
  have h_refl : ∀ t : Lam, Par t t := by
    intro t; induction t <;> tauto;
  exact h_refl t

/-
A single β-step is a parallel step.
-/
theorem par_of_beta {t u : Lam} (h : Beta t u) : Par t u := by
  induction h;
  · exact Par.beta ( par_refl _ ) ( par_refl _ );
  · exact Par.app ‹_› ( par_refl _ );
  · exact Par.app ( par_refl _ ) ‹_›;
  · exact Par.lam ‹_›

/-! ### `Par` respects the substitution algebra -/

/-
Parallel reduction commutes with lifting.
-/
theorem par_lift {t t' : Lam} (h : Par t t') (c : ℕ) :
    Par (lift c t) (lift c t') := by
      induction h generalizing c;
      · exact par_refl _;
      · exact Par.lam ( by solve_by_elim );
      · exact Par.app ( by solve_by_elim ) ( by solve_by_elim );
      · rename_i h₁ h₂ h₃ h₄;
        convert Par.beta ( h₃ ( c + 1 ) ) ( h₄ c ) using 1;
        convert lift_subst_ge _ ( Nat.zero_le c ) _ using 1

/-
Parallel reduction is a congruence for substitution.
-/
theorem par_subst {s s' t t' : Lam} (hs : Par s s') (ht : Par t t') (j : ℕ) :
    Par (subst j s t) (subst j s' t') := by
      induction' ht with a a' b b' ha hb ih generalizing j s s';
      · by_cases h : a = j <;> simp_all +decide [ subst ];
        split_ifs <;> [ exact par_refl _; exact par_refl _ ];
      · exact Par.lam ( ha b' ( j + 1 ) |> fun h => by
          exact ha ( par_lift hs 0 ) _ );
      · exact Par.app ( by solve_by_elim ) ( by solve_by_elim );
      · rename_i h₁ h₂ h₃ h₄;
        convert Par.beta _ _ using 1;
        convert subst0_subst _ _ _ _ using 1;
        · exact h₃ ( par_lift hs 0 ) _;
        · exact h₄ hs j

/-- Parallel reduction is a congruence for β-contraction. -/
theorem par_subst0 {u u' t t' : Lam} (hu : Par u u') (ht : Par t t') :
    Par (subst0 u t) (subst0 u' t') :=
  par_subst hu ht 0

/-! ### Complete development and the triangle property -/

/-- Takahashi's **complete development**: contract *all* the redexes currently
present in `t`. -/
def cd : Lam → Lam
  | var n => var n
  | lam t => lam (cd t)
  | app (lam t) u => subst0 (cd u) (cd t)
  | app a b => app (cd a) (cd b)

/-
**Triangle property**: every parallel reduct of `t` parallel-reduces to the
complete development `cd t`.
-/
theorem par_triangle {t u : Lam} (h : Par t u) : Par u (cd t) := by
  induction' t with t ih generalizing u;
  · cases h ; tauto;
  · cases h;
    exact Par.lam ( by solve_by_elim );
  · rename_i a b ih_a ih_b;
    induction a <;> simp_all +decide [ cd ];
    · rcases h with ( _ | _ | _ | _ ) ; tauto;
    · cases h;
      · rename_i a' b' ha hb ih;
        cases' ha with a'' ha'';
        exact Par.beta ( ih_a ( Par.lam ‹_› ) |> fun h => by cases h; assumption ) ( ih_b hb );
      · rename_i k hk₁ hk₂ hk₃;
        exact par_subst0 ( ih_b hk₂ ) ( ih_a ( Par.lam hk₁ ) |> fun h => by cases h; tauto );
    · cases h;
      exact Par.app ( ih_a ‹_› ) ( ih_b ‹_› )

/-- **Diamond property** of parallel reduction. -/
theorem par_diamond {t u v : Lam} (hu : Par t u) (hv : Par t v) :
    ∃ w, Par u w ∧ Par v w :=
  ⟨cd t, par_triangle hu, par_triangle hv⟩

/-! ### From `Par` back to `Beta` -/

/-
`BetaStar` is a congruence under `lam`.
-/
theorem betaStar_lam {t t' : Lam} (h : BetaStar t t') : BetaStar (lam t) (lam t') := by
  obtain ⟨l, hl⟩ := h;
  · constructor;
  · rename_i h₁ h₂;
    exact h₁.lift ( fun x => lam x ) ( fun a b h => Beta.lam h ) |> fun h => h.tail ( Beta.lam h₂ )

/-
`BetaStar` is a congruence in the left argument of an application.
-/
theorem betaStar_appL {a a' : Lam} (h : BetaStar a a') (b : Lam) :
    BetaStar (app a b) (app a' b) := by
      induction h;
      · constructor;
      · exact Relation.ReflTransGen.tail ‹_› ( Beta.appL _ ‹_› )

/-
`BetaStar` is a congruence in the right argument of an application.
-/
theorem betaStar_appR (a : Lam) {b b' : Lam} (h : BetaStar b b') :
    BetaStar (app a b) (app a b') := by
      induction h;
      · constructor;
      · exact Relation.ReflTransGen.tail ‹_› ( Beta.appR _ ‹_› )

/-
A parallel step is realised by a finite β-reduction sequence.
-/
theorem betaStar_of_par {t u : Lam} (h : Par t u) : BetaStar t u := by
  revert u;
  induction' t with t ih;
  · rintro u ( hu | hu | hu | hu ) ; tauto;
  · intro u hu; cases hu;
    exact betaStar_lam (by solve_by_elim);
  · intro u hu; cases hu;
    · exact Relation.ReflTransGen.trans ( betaStar_appL ( by solve_by_elim ) _ ) ( betaStar_appR _ ( by solve_by_elim ) );
    · rename_i t ht u hu;
      rename_i a ha;
      rename_i b hb;
      convert Relation.ReflTransGen.tail ( Relation.ReflTransGen.trans ( betaStar_appL ( u ( Par.lam ht ) ) b ) ( betaStar_appR _ ( hb hu ) ) ) ( Beta.beta _ _ ) using 1

/-! ### Church–Rosser -/

/-- The reflexive–transitive closures of `Beta` and `Par` coincide. -/
theorem reflTransGen_beta_iff_par (t u : Lam) :
    Relation.ReflTransGen Beta t u ↔ Relation.ReflTransGen Par t u := by
  constructor
  · exact Relation.ReflTransGen.mono (fun _ _ => par_of_beta)
  · intro h
    induction h with
    | refl => exact Relation.ReflTransGen.refl
    | tail _ hbc ih => exact ih.trans (betaStar_of_par hbc)

/-- **Church–Rosser / confluence of β-reduction.**  Any two β-reduction
sequences from a common term can be joined. -/
theorem church_rosser_beta {t u v : Lam} (h1 : BetaStar t u) (h2 : BetaStar t v) :
    ∃ w, BetaStar u w ∧ BetaStar v w := by
  have h1' : Relation.ReflTransGen Par t u :=
    (reflTransGen_beta_iff_par t u).1 h1
  have h2' : Relation.ReflTransGen Par t v :=
    (reflTransGen_beta_iff_par t v).1 h2
  have key : ∀ a b c : Lam, Par a b → Par a c →
      ∃ d, Relation.ReflGen Par b d ∧ Relation.ReflTransGen Par c d := by
    intro a b c hab hac
    obtain ⟨d, hbd, hcd⟩ := par_diamond hab hac
    exact ⟨d, Relation.ReflGen.single hbd, Relation.ReflTransGen.single hcd⟩
  obtain ⟨w, huw, hvw⟩ := Relation.church_rosser key h1' h2'
  exact ⟨w, (reflTransGen_beta_iff_par u w).2 huw, (reflTransGen_beta_iff_par v w).2 hvw⟩

end LambdaCalculus