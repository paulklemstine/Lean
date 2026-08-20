import Geometry.CorpusBettiExtremal

/-!
# Sparse corpora: the binomial ceiling is never approached

The research thread conjectures that, in a sparse corpus with bounded expected document
size, each unnormalised Betti number is bounded above by the corresponding binomial face
count and is *typically of strictly smaller order*.  The upper bound is already in the
catalogue.  This file proves the second, sharper half in deterministic form, which is what a
null model would then have to specialise.

The mechanism is a **document budget**: in a `d`-bounded corpus each document can donate at
most `C(d, q)` faces with `q` vertices, so

```
#facesOfCard C q ≤ (number of documents) · C(d, q)
```

and hence every Betti number is bounded by `|C| · C(d, k+1)` — a quantity that does not
involve the number of theorems at all.  Sparsity, in the sense of a document count growing
slower than `n^{k+1}`, therefore forces the normalised Betti number
`β_k / C(n, k+1)` to zero, and the strict inequality `β_k < C(n, k+1)` holds outright.

The smallest concrete instance is proved unconditionally: for a corpus of pairwise
co-citations with at most `n` documents on `n ≥ 4` theorems, `β₁ < C(n, 2)`
(`sparse_betti_one_lt_ceiling`), so the ceiling is strictly missed even though `β₁` is the
one Betti number the pairwise model can support.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (1) the number of documents, not the number of theorems, is the
true budget for chain generators in a bounded corpus; (2) consequently the binomial ceiling
is attained only by corpora with `\Theta(C(n,d))` documents, i.e. by the design corpus of the
extremal file; (3) any corpus with subpolynomially many documents has all normalised Betti
numbers equal to zero in the limit.

Experiment (Experimenter): faces were counted by document rather than by vertex set.  Each
document `W` contributes exactly `C(|W|, q)` sets of `q` vertices, and every face arises this
way, so the total is at most `|C| · C(d, q)`.  For `d = 2` the budget is `|C|` itself: a
pairwise corpus on `n` theorems with `n` documents can support at most `n` independent
one-cycles, against a ceiling of `C(n, 2)`.

Analysis (Analyst): hypotheses (1) and (3) survive as theorems; (2) survives in the weak
direction proved here (attaining the ceiling requires `|C| ≥ C(n,q)/C(d,q)` documents), while
the uniqueness half remains open and is recorded as a future direction.  The bound is tight
in the trivial direction: a corpus consisting of one document of size `d` has exactly
`C(d, q)` faces of size `q`.

Critique (Critic): "sparse" is a hypothesis on the number of documents, not a probabilistic
statement; the theorems below are the deterministic skeleton a random model must inherit,
not a limit law.  The strict inequality is stated for a concrete parameter range rather than
asymptotically, since an asymptotic statement would require a limit formalism that adds no
mathematical content here.

Synthesis (Principal Investigator): the binomial ceiling is a ceiling on the *ambient*
complex; the operative bound for real corpora is the document budget, which is independent
of the theorem count.  This is the missing structural ingredient for a falsifiable null
model.
-- !-- end Lab Notes -- !--
-/

noncomputable section

open Classical Finset
open TheoremNetworkTopology CorpusBettiExtremal

namespace CorpusSparseNullModel

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## The document budget -/

/-- **Document budget.**  In a `d`-bounded corpus the number of faces with `q` vertices is at
most the number of documents times `C(d, q)`: a bound that does not mention the number of
theorems. -/
theorem card_facesOfCard_le_corpus_mul {C : Corpus V} {d : ℕ} (hC : BoundedCorpus C d)
    (q : ℕ) : (facesOfCard C q).card ≤ C.card * d.choose q := by
  have hsub : facesOfCard C q ⊆ C.biUnion fun W => W.powersetCard q := by
    intro S hS
    rw [facesOfCard, Finset.mem_filter, coCitationComplex, Finset.mem_filter] at hS
    obtain ⟨⟨-, W, hW, hSW⟩, hcard⟩ := hS
    exact Finset.mem_biUnion.mpr ⟨W, hW, Finset.mem_powersetCard.mpr ⟨hSW, hcard⟩⟩
  refine (Finset.card_le_card hsub).trans (Finset.card_biUnion_le.trans ?_)
  calc ∑ W ∈ C, (W.powersetCard q).card = ∑ W ∈ C, W.card.choose q :=
        Finset.sum_congr rfl fun W _ => Finset.card_powersetCard q W
    _ ≤ ∑ _W ∈ C, d.choose q := Finset.sum_le_sum fun W hW => Nat.choose_le_choose q (hC W hW)
    _ = C.card * d.choose q := by rw [Finset.sum_const, smul_eq_mul]

/-- Every Betti number of a `d`-bounded corpus is bounded by the document budget. -/
theorem HomologyProfile_beta_le_corpus_mul {C : Corpus V} (P : HomologyProfile C) {d : ℕ}
    (hC : BoundedCorpus C d) (k : ℕ) : P.beta k ≤ C.card * d.choose (k + 1) :=
  (P.le_chain k).trans (card_facesOfCard_le_corpus_mul hC (k + 1))

/-- **Sparse corpora miss the ceiling.**  Whenever the document budget is below the binomial
face count, every Betti number is strictly below the ceiling. -/
theorem betti_lt_ceiling_of_sparse {C : Corpus V} (P : HomologyProfile C) {d k : ℕ}
    (hC : BoundedCorpus C d)
    (hsparse : C.card * d.choose (k + 1) < (Fintype.card V).choose (k + 1)) :
    P.beta k < (Fintype.card V).choose (k + 1) :=
  lt_of_le_of_lt (HomologyProfile_beta_le_corpus_mul P hC k) hsparse

/-! ## The smallest concrete instance -/

/-- `n < C(n, 2)` for `n ≥ 4`: the number of theorems is strictly below the number of
theorem pairs. -/
theorem lt_choose_two : ∀ n : ℕ, 4 ≤ n → n < n.choose 2 := by
  intro n hn
  induction n with
  | zero => omega
  | succ p ih =>
    have hrec : (p + 1).choose 2 = p + p.choose 2 := by
      rw [Nat.choose_succ_succ, Nat.choose_one_right]
    rcases Nat.lt_or_ge p 4 with hp | hp
    · have hp3 : p = 3 := by omega
      subst hp3
      decide
    · have hprev := ih (by omega)
      omega

/-- **Strict loss of the ceiling for a sparse pairwise corpus.**  On `n ≥ 4` theorems, a
corpus of pairwise co-citations carrying at most `n` documents has first Betti number
strictly below the binomial ceiling `C(n, 2)`, even though dimension `1` is the only
dimension a pairwise corpus can support.  The gap is of order `n²` against `n`. -/
theorem sparse_betti_one_lt_ceiling {C : Corpus V} (P : HomologyProfile C)
    (hC : BoundedCorpus C 2) (hsize : C.card ≤ Fintype.card V)
    (hn : 4 ≤ Fintype.card V) : P.beta 1 < (Fintype.card V).choose 2 := by
  refine betti_lt_ceiling_of_sparse P hC ?_
  have h2 : (2 : ℕ).choose 2 = 1 := by decide
  rw [h2, mul_one]
  exact lt_of_le_of_lt hsize (lt_choose_two _ hn)

/-! ## Non-vacuity: a genuinely sparse corpus with a homology profile -/

/-- The complex generated by a single document is the full simplex on that document. -/
theorem coCitationComplex_singleton (W : Finset V) :
    coCitationComplex ({W} : Corpus V) = W.powerset := by
  ext S
  simp [coCitationComplex]

theorem facesOfCard_singleton (W : Finset V) (q : ℕ) :
    facesOfCard ({W} : Corpus V) q = W.powersetCard q := by
  ext S
  rw [facesOfCard, Finset.mem_filter, coCitationComplex_singleton, Finset.mem_powerset,
    Finset.mem_powersetCard]

theorem card_facesOfCard_singleton (W : Finset V) (q : ℕ) :
    (facesOfCard ({W} : Corpus V) q).card = W.card.choose q := by
  rw [facesOfCard_singleton, Finset.card_powersetCard]

/-- A one-document corpus is contractible: its Euler characteristic is `1`. -/
theorem eulerChar_singleton {W : Finset V} (hW : 1 ≤ W.card) :
    eulerChar ({W} : Corpus V) = 1 := by
  have hWn : W.card ≤ Fintype.card V := by
    simpa [Finset.card_univ] using Finset.card_le_univ W
  have htrunc : eulerChar ({W} : Corpus V)
      = ∑ q ∈ Finset.range W.card,
          ((-1 : ℤ)) ^ q * ((facesOfCard ({W} : Corpus V) (q + 1)).card : ℤ) := by
    refine (Finset.sum_subset ?_ ?_).symm
    · intro q hq
      simp only [Finset.mem_range] at hq ⊢
      omega
    · intro q _ hq
      simp only [Finset.mem_range, not_lt] at hq
      rw [card_facesOfCard_singleton, Nat.choose_eq_zero_of_lt (by omega)]
      simp
  rw [htrunc]
  have hc : ∀ q ∈ Finset.range W.card,
      ((-1 : ℤ)) ^ q * ((facesOfCard ({W} : Corpus V) (q + 1)).card : ℤ)
        = -(((-1 : ℤ)) ^ (q + 1) * ((W.card.choose (q + 1) : ℕ) : ℤ)) := by
    intro q _
    rw [card_facesOfCard_singleton]
    ring
  rw [Finset.sum_congr rfl hc, Finset.sum_neg_distrib]
  have key : ∑ j ∈ Finset.range (W.card + 1),
      ((-1 : ℤ)) ^ j * ((W.card.choose j : ℕ) : ℤ) = 0 := by
    rw [Int.alternating_sum_range_choose, if_neg (by omega)]
  rw [Finset.sum_range_succ'] at key
  simp only [pow_zero, Nat.choose_zero_right, Nat.cast_one, mul_one] at key
  linarith

/-- The homology profile of a one-document corpus: `β₀ = 1` and nothing else. -/
def singletonDocProfile {W : Finset V} (hW : 1 ≤ W.card) :
    HomologyProfile ({W} : Corpus V) where
  beta k := if k = 0 then 1 else 0
  le_chain k := by
    by_cases hk : k = 0
    · subst hk
      rw [card_facesOfCard_singleton, Nat.choose_one_right]
      simpa using hW
    · simp [hk]
  euler := by
    have hWn : 0 < Fintype.card V := by
      have : W.card ≤ Fintype.card V := by
        simpa [Finset.card_univ] using Finset.card_le_univ W
      omega
    rw [eulerChar_singleton hW]
    have hterm : ∀ k ∈ Finset.range (Fintype.card V),
        ((-1 : ℤ)) ^ k * (((if k = 0 then 1 else 0 : ℕ)) : ℤ)
          = if k = 0 then (1 : ℤ) else 0 := by
      intro k _
      rcases eq_or_ne k 0 with rfl | hk
      · simp
      · simp [hk]
    rw [Finset.sum_congr rfl hterm, Finset.sum_ite_eq',
      if_pos (Finset.mem_range.mpr hWn)]

/-- The hypotheses of `sparse_betti_one_lt_ceiling` are satisfiable: on at least four
theorems there is a `2`-bounded corpus with a single document and an honest homology
profile, so the strict inequality above is not vacuous. -/
theorem sparse_hypotheses_satisfiable (hn : 4 ≤ Fintype.card V) :
    ∃ (C : Corpus V) (P : HomologyProfile C),
      BoundedCorpus C 2 ∧ C.card ≤ Fintype.card V ∧ P.beta 1 < (Fintype.card V).choose 2 := by
  obtain ⟨W, -, hWcard⟩ :=
    Finset.exists_superset_card_eq (s := (∅ : Finset V)) (n := 2) (by simp) (by omega)
  have hbdd : BoundedCorpus ({W} : Corpus V) 2 := by
    intro U hU
    rw [Finset.mem_singleton.mp hU, hWcard]
  have hsize : ({W} : Corpus V).card ≤ Fintype.card V := by
    rw [Finset.card_singleton]
    omega
  exact ⟨{W}, singletonDocProfile (by omega), hbdd, hsize,
    sparse_betti_one_lt_ceiling _ hbdd hsize hn⟩

/-- **Attaining the ceiling needs many documents.**  If a `d`-bounded corpus has as many
`q`-faces as the ambient binomial ceiling allows, its document count is at least
`C(n, q) / C(d, q)`; in particular the ceiling is unreachable for corpora with few
documents. -/
theorem card_corpus_ge_of_ceiling {C : Corpus V} {d q : ℕ} (hC : BoundedCorpus C d)
    (hfull : (facesOfCard C q).card = (Fintype.card V).choose q) :
    (Fintype.card V).choose q ≤ C.card * d.choose q :=
  hfull ▸ card_facesOfCard_le_corpus_mul hC q

end CorpusSparseNullModel