import Mathlib

/-!
# Shamir's `(t, n)` Secret Sharing: Reconstruction and Information-Theoretic Privacy

This file formalizes the two foundational guarantees of **Shamir's secret sharing scheme**
over an arbitrary field `F` (e.g. `ZMod p`).

A dealer encodes a secret `c : F` as the constant term `f.eval 0` of a polynomial `f`
of degree `< t`.  The *share* handed to a participant sitting at evaluation point `x`
is `f.eval x`.  The participants' points are distinct nonzero elements collected in a
finset `s ⊆ F`.

## Main results

* `shamir_reconstruction` — **threshold = degree + 1.**  Any `t` distinct shares
  determine the sharing polynomial uniquely: two polynomials of degree `< t` that agree
  on a finset `s` of size `t` are equal.  Hence `t` shares recover the secret.

* `shamir_privacy` — **perfect (information-theoretic) secrecy.**  Fix the `t - 1` shares
  observed by a coalition (`s` with `0 ∉ s`, `#s = t - 1`).  Then for *every* candidate
  secret `c : F` there is a **unique** polynomial of degree `< t` consistent with those
  shares and with `f.eval 0 = c`.  So the observed shares are equally compatible with
  every secret: `t - 1` shares reveal zero information.

* `shamir_insufficient` — the immediate contrapositive of reconstruction below threshold:
  two *distinct* secrets are both consistent with the same `t - 1` shares.

This bridges the **Cryptography** and **Algebra / Linear-Algebra (Lagrange interpolation)**
domains of the catalog: the security of Shamir's scheme is exactly the statement that the
evaluation map `degreeLT F t → (nodes → F)` is a bijection (`Lagrange.funEquivDegreeLT`).
-/

namespace ShamirSecretSharing

open Polynomial

variable {F : Type*} [Field F]

/-
**Reconstruction / threshold = degree + 1.**
Two polynomials of degree `< t` that agree on a finset `s` of `t` distinct evaluation
points are identical.  Operationally: any `t` shares of a degree-`< t` sharing polynomial
determine it uniquely, hence recover the secret `f.eval 0`.
-/
theorem shamir_reconstruction {t : ℕ} (s : Finset F) (hcard : s.card = t)
    (f g : F[X]) (hf : f.degree < t) (hg : g.degree < t)
    (hshares : ∀ x ∈ s, f.eval x = g.eval x) : f = g := by
  refine' Polynomial.eq_of_degree_sub_lt_of_eval_finset_eq _ _ _;
  exact s;
  · exact lt_of_le_of_lt ( Polynomial.degree_sub_le _ _ ) ( max_lt ( by simpa [ hcard ] using hf ) ( by simpa [ hcard ] using hg ) );
  · exact hshares

/-
The secret is recovered from `t` shares: under the reconstruction hypotheses the
constant terms agree.
-/
theorem shamir_secret_recovered {t : ℕ} (s : Finset F) (hcard : s.card = t)
    (f g : F[X]) (hf : f.degree < t) (hg : g.degree < t)
    (hshares : ∀ x ∈ s, f.eval x = g.eval x) : f.eval 0 = g.eval 0 := by
  rw [ shamir_reconstruction s hcard f g hf hg hshares ]

/-
**Information-theoretic privacy of Shamir's scheme.**
Let `s` be the set of evaluation points held by a coalition of `t - 1` participants
(`0 ∉ s` is the dealer's secret point, `#s = t - 1`), and let `y` record their observed
shares.  Then for *every* candidate secret `c` there is a **unique** sharing polynomial of
degree `< t` that reproduces the observed shares and has secret `c`.

Existence + uniqueness for *every* `c` means the coalition's view is compatible with each
secret in exactly one way: the `t - 1` shares carry no information about the secret.
-/
theorem shamir_privacy {t : ℕ} (s : Finset F)
    (h0 : (0 : F) ∉ s) (hcard : s.card = t - 1) (ht : 1 ≤ t)
    (y : F → F) (c : F) :
    ∃! f : F[X], f.degree < t ∧ f.eval 0 = c ∧ ∀ x ∈ s, f.eval x = y x := by
  -- Let's choose any polynomial $f$ of degree less than $t$ that satisfies the conditions.
  obtain ⟨f, hf⟩ : ∃ f : F[X], f.degree < t ∧ f.eval 0 = c ∧ ∀ x ∈ s, f.eval x = y x := by
    rcases t with ( _ | t ) <;> simp_all +decide;
    -- By Lagrange interpolation, there exists a unique polynomial $f$ of degree at most $t$ such that $f(x) = y(x)$ for all $x \in s$ and $f(0) = c$.
    have h_interpolate : ∃ f : F[X], f.degree ≤ t ∧ f.eval 0 = c ∧ ∀ x ∈ s, f.eval x = y x := by
      -- Consider the polynomial $f(x) = c + \sum_{x_i \in s} y(x_i) \prod_{x_j \in s \setminus \{x_i\}} \frac{x - x_j}{x_i - x_j}$.
      obtain ⟨f, hf⟩ : ∃ f : Polynomial F, f.degree ≤ s.card ∧ (∀ x ∈ s, f.eval x = y x) ∧ f.eval 0 = c := by
        -- By Lagrange interpolation, there exists a unique polynomial $f$ of degree at most $t$ such that $f(x) = y(x)$ for all $x \in s$.
        obtain ⟨f, hf⟩ : ∃ f : Polynomial F, f.degree ≤ s.card ∧ (∀ x ∈ s, f.eval x = y x) := by
          -- By Lagrange interpolation, there exists a polynomial $f$ of degree at most $t-1$ such that $f(x) = y(x)$ for all $x \in s$. Use this fact.
          have h_interpolate : ∀ (s : Finset F) (y : F → F), ∃ f : F[X], f.degree ≤ s.card ∧ (∀ x ∈ s, f.eval x = y x) := by
            intro s y;
            induction' s using Finset.induction with x s hx ih;
            exact ⟨ 0, bot_le, by simp +decide ⟩;
            obtain ⟨ f, hf₁, hf₂ ⟩ := ih;
            -- Let $g(x) = f(x) + (y(x) - f(x)) \prod_{x_i \in s} \frac{x - x_i}{x - x_i}$.
            obtain ⟨g, hg⟩ : ∃ g : F[X], g.degree ≤ s.card ∧ g.eval x = y x - f.eval x ∧ ∀ x_i ∈ s, g.eval x_i = 0 := by
              refine' ⟨ Polynomial.C ( ( y x - f.eval x ) / ∏ x_i ∈ s, ( x - x_i ) ) * ∏ x_i ∈ s, ( Polynomial.X - Polynomial.C x_i ), _, _, _ ⟩;
              · simp +decide [ Polynomial.degree_prod ];
                exact add_le_of_nonpos_left ( Polynomial.degree_C_le );
              · simp +decide [ Polynomial.eval_prod, Finset.prod_eq_zero_iff, sub_eq_zero, hx ];
              · simp +contextual [ Finset.prod_eq_prod_diff_singleton_mul ];
                exact fun x_i hx_i => Or.inr ( by rw [ Polynomial.eval_prod ] ; exact Finset.prod_eq_zero hx_i ( by simp +decide ) );
            refine' ⟨ f + g, _, _ ⟩ <;> simp_all +decide [ Finset.card_insert_of_notMem ];
            · exact le_trans ( Polynomial.degree_add_le _ _ ) ( max_le ( le_trans hf₁ ( WithBot.coe_le_coe.mpr ( Nat.le_succ _ ) ) ) ( le_trans hg.1 ( WithBot.coe_le_coe.mpr ( Nat.le_succ _ ) ) ) );
            · exact Classical.decEq F;
          exact h_interpolate s y;
        -- Let $g(x) = f(x) + (c - f(0)) \prod_{x_i \in s} \frac{x - x_i}{0 - x_i}$.
        use f + Polynomial.C (c - f.eval 0) * Finset.prod s (fun x => Polynomial.C (1 / (-x)) * (Polynomial.X - Polynomial.C x));
        refine' ⟨ le_trans ( Polynomial.degree_add_le _ _ ) ( max_le hf.1 _ ), _, _ ⟩ <;> simp_all +decide [ Polynomial.eval_prod ];
        · refine' le_trans ( add_le_add ( Polynomial.degree_sub_le _ _ ) ( Polynomial.degree_prod_le _ _ ) ) _ ; simp +decide [ * ];
          exact le_trans ( add_le_add ( max_le ( Polynomial.degree_C_le ) ( Polynomial.degree_C_le ) ) ( Finset.sum_le_sum fun x hx => add_le_add ( Polynomial.degree_C_le ) le_rfl ) ) ( by simp +decide [ hcard ] );
        · exact fun x hx => Or.inr ( Finset.prod_eq_zero hx ( by simp +decide ) );
        · rw [ Finset.prod_congr rfl fun x hx => inv_mul_cancel₀ ( by aesop ) ] ; aesop;
      aesop;
    exact ⟨ h_interpolate.choose, lt_of_le_of_lt h_interpolate.choose_spec.1 ( WithBot.coe_lt_coe.mpr ( Nat.lt_succ_self _ ) ), h_interpolate.choose_spec.2.1, h_interpolate.choose_spec.2.2 ⟩;
  refine' ⟨ f, hf, _ ⟩;
  intro g hg;
  apply shamir_reconstruction;
  module;
  any_goals exact Finset.cons 0 s h0;
  · grind;
  · grind +extAll;
  · grind

/-
**Sub-threshold ambiguity.**  Below the threshold the secret is genuinely undetermined:
for any two distinct candidate secrets `c₁ ≠ c₂` there are two *different* polynomials of
degree `< t`, both consistent with the same `t - 1` observed shares, with secrets `c₁` and
`c₂` respectively.  This is the sharp converse of `shamir_reconstruction`.
-/
theorem shamir_insufficient {t : ℕ} (s : Finset F)
    (h0 : (0 : F) ∉ s) (hcard : s.card = t - 1) (ht : 1 ≤ t)
    (y : F → F) (c₁ c₂ : F) (hc : c₁ ≠ c₂) :
    ∃ f g : F[X], f.degree < t ∧ g.degree < t ∧
      (∀ x ∈ s, f.eval x = y x) ∧ (∀ x ∈ s, g.eval x = y x) ∧
      f.eval 0 = c₁ ∧ g.eval 0 = c₂ ∧ f ≠ g := by
  obtain ⟨f₁, hf₁⟩ : ∃ f₁ : F[X], f₁.degree < t ∧ f₁.eval 0 = c₁ ∧ ∀ x ∈ s, f₁.eval x = y x := by
    convert ShamirSecretSharing.shamir_privacy s h0 hcard ht y c₁ |> ExistsUnique.exists
  obtain ⟨f₂, hf₂⟩ : ∃ f₂ : F[X], f₂.degree < t ∧ f₂.eval 0 = c₂ ∧ ∀ x ∈ s, f₂.eval x = y x := by
    exact ExistsUnique.exists ( ShamirSecretSharing.shamir_privacy s h0 hcard ht y c₂ );
  grind

end ShamirSecretSharing

/-
-- !-- Lab Notes -- !--

CATEGORY (menu balance): Cross-domain BRIDGE — Cryptography ⟷ Algebra / Linear Algebra
(Lagrange interpolation, `degreeLT`, `Polynomial.eval`).  The security of an applied
cryptographic primitive is reduced to a pure interpolation-theoretic statement.

HYPOTHESIS (Hypothesizer).
  H1.  A degree-`< t` polynomial over a field is uniquely pinned down by ANY `t` of its
       evaluations ("reconstruction threshold = degree + 1").
  H2 (bold).  `t - 1` evaluations carry ZERO information about `f.eval 0`: for every
       candidate secret `c` there is exactly one consistent degree-`< t` polynomial, so the
       coalition's view is a bijective re-labelling of the secret space.  This is the
       information-theoretic-security claim, recast as a per-secret existence+uniqueness.
  H3.  Below threshold the secret is genuinely ambiguous (sharp converse of H1).

EXPERIMENT (Experimenter).
  * `shamir_reconstruction` — proved via `Polynomial.eq_of_degree_sub_lt_of_eval_finset_eq`
    after rewriting the degree bounds through `hcard : s.card = t`.
  * `shamir_secret_recovered` — corollary: equal polynomials ⇒ equal constant terms.
  * `shamir_privacy` — proved by an explicit construction of the consistent interpolant on
    the augmented node set `insert 0 s` (size `t`), with uniqueness from reconstruction.
  * `shamir_insufficient` — instantiate `shamir_privacy` at two distinct secrets `c₁ ≠ c₂`;
    the two interpolants differ because their constant terms differ.

ANALYSIS (Analyst).
  The pivotal structural fact is that `0` (the secret point) must be ADJOINED to the `t - 1`
  observed nodes to form a `t`-node interpolation problem.  Once `#(insert 0 s) = t`, the
  evaluation map `degreeLT F t → (nodes → F)` is a bijection (`Lagrange.funEquivDegreeLT`),
  which simultaneously yields existence (privacy) and uniqueness (reconstruction).  Security
  and reconstruction are therefore two readings of the SAME bijection at cardinalities `t-1`
  and `t`.  Failure mode encountered while sketching: trying to interpolate on `s` alone
  (size `t-1`) under-determines the polynomial — exactly why the scheme is private.

CRITIQUE (Critic).
  * Non-triviality: proofs use `Polynomial.ext`-level interpolation machinery, an explicit
    interpolant construction and `ExistsUnique`; none is `rfl`/`decide`/`simp`-only.
  * Hidden-hypothesis check: `0 ∉ s` is load-bearing (else the secret node clashes with an
    observed node and `#(insert 0 s) = t-1 < t`); `1 ≤ t` prevents the degenerate `t = 0`
    where `s.card = t - 1 = 0` would be vacuous.  Both are stated, not smuggled.
  * `shamir_privacy` is an honest `∃!`, not a vacuous truth: the witness is exhibited.

SYNTHESIS (PI).
  Shamir privacy ⇔ reconstruction-below-threshold-fails ⇔ the interpolation map is a
  bijection.  Verified axioms: only `propext`, `Classical.choice`, `Quot.sound`.
-/