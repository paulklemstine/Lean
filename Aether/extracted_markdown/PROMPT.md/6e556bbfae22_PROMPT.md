## Research Task: GL3 tropical Satake certified robustness for instant-runoff (ranked-choice) Hecke-score classifiers

**Research Mode: PROVE**

Develop a formal robustness theory for a deterministic, tie-free instant-runoff / sequential-elimination classifier built from multiclass tropical score maps. The core objective is to show that sufficiently large round-wise score gaps imply invariance of the entire elimination order, hence invariance of the final winner, under all `‖·‖∞` perturbations in an explicit radius.

This should be set up in a way that is independent of the detailed GL3 Satake construction once one has a uniform Lipschitz bound on the score coordinates. The GL3/tropical content enters through the hypothesis that each score coordinate is certified Lipschitz with a common constant `K` (or a coordinatewise family `K i`), so the theorem cleanly composes with existing tropical certified-robustness infrastructure.

---

### 1. Deterministic elimination on finite candidate sets

Work with a fixed number of classes `m : ℕ` and score vectors `v : Fin m → ℝ`. Since IRV with “transfer according to induced ranking by scores” is cumbersome to encode directly, first formalize the equivalent deterministic *sequential elimination by current minimum score* in the tie-free setting: at each round, among the currently active candidates, eliminate the unique candidate of minimal score; the winner is the unique remaining candidate. Because the score vector is static, the elimination order is simply the order induced by the scores, but it is important to prove this through the recursive elimination mechanism, since that is the combinatorial object whose stability will later be certified.

A good core definition is:

```lean
def roundLoser {m : ℕ} (S : Finset (Fin m)) (v : Fin m → ℝ) : Fin m := ...
```

with hypotheses ensuring `S.Nonempty` and uniqueness of the minimizer on `S`.

Then define recursively:

```lean
def eliminationOrder {m : ℕ} (v : Fin m → ℝ) : List (Fin m) := ...
def irvWinner {m : ℕ} (v : Fin m → ℝ) : Fin m := ...
```

where `eliminationOrder v` lists candidates from first eliminated to winner, and `irvWinner v` is the last surviving candidate. You may prefer a recursion on `Finset.card S` with an auxiliary function

```lean
def eliminationOrderOn {m : ℕ} :
    (S : Finset (Fin m)) → (hS : S.Nonempty) → (v : Fin m → ℝ) → List (Fin m)
```

and then specialize to `S = Finset.univ`.

A useful tie-free hypothesis on a candidate set `S` is:

```lean
def PairwiseDistinctOn {m : ℕ} (S : Finset (Fin m)) (v : Fin m → ℝ) : Prop :=
  ∀ ⦃i⦄, i ∈ S → ∀ ⦃j⦄, j ∈ S → i ≠ j → v i ≠ v j
```

Under this hypothesis, every nonempty subset `T ⊆ S` has a unique minimizer. Prove this once as a reusable lemma.

---

### 2. Round-gap and margin definitions

Define the elimination gap on a nonempty active set `S` to be the difference between the second-smallest and smallest score on `S`. Since this is easiest to use via a pointwise characterization, define:

```lean
def IsRoundLoser {m : ℕ} (S : Finset (Fin m)) (v : Fin m → ℝ) (i : Fin m) : Prop :=
  i ∈ S ∧ ∀ j ∈ S, v i ≤ v j

def RoundGapAt {m : ℕ} (S : Finset (Fin m)) (v : Fin m → ℝ) (i : Fin m) : ℝ :=
  sInf {δ : ℝ | ∃ j ∈ S, j ≠ i ∧ δ = v j - v i}
```

but for proofs it is often cleaner to avoid `sInf` and instead use the directly quantified “strict gap certificate”:

```lean
def HasGapAtLeast {m : ℕ} (S : Finset (Fin m)) (v : Fin m → ℝ) (i : Fin m) (γ : ℝ) : Prop :=
  i ∈ S ∧ ∀ j ∈ S, j ≠ i → v i + γ ≤ v j
```

This is the right notion for robust preservation of the minimizer.

Then define a recursive predicate saying that an entire elimination sequence is gap-certified by `γ` at every round:

```lean
def EliminationGapCertified {m : ℕ} :
    (S : Finset (Fin m)) → (hS : S.Nonempty) → (v : Fin m → ℝ) → (γ : ℝ) → Prop
```

meaning:
- if `S.card = 1`, it holds trivially;
- otherwise, letting `i` be the current loser, `HasGapAtLeast S v i γ` holds and the predicate recurses on `S.erase i`.

This recursive certificate is much easier to induct on than trying to define a single minimum over all rounds immediately.

If desired, later define the explicit minimum round gap:

```lean
def minRoundGap {m : ℕ} (v : Fin m → ℝ) : ℝ := ...
```

but the inductive theorem should be proved first using `EliminationGapCertified`.

---

### 3. Perturbation model and Lipschitz hypotheses

Use `x x' : Fin d → ℝ` as inputs, with the `L∞` ball encoded by

```lean
def LinftyDist {d : ℕ} (x x' : Fin d → ℝ) : ℝ :=
  ⨆ i, |x i - x' i|
```

or, if easier in Mathlib, avoid defining the norm globally and instead assume the coordinatewise bound

```lean
∀ k, |x' k - x k| ≤ r
```

which is exactly what the robustness proof uses.

Let the score map be

```lean
s : (Fin d → ℝ) → (Fin m → ℝ)
```

or equivalently `s i x`. Assume a uniform coordinatewise Lipschitz bound:

```lean
def ScoreLipschitzInf (s : (Fin d → ℝ) → Fin m → ℝ) (K r : ℝ) : Prop :=
  ∀ x x', (∀ k, |x' k - x k| ≤ r) → ∀ i, |s x' i - s x i| ≤ K * r
```

More generally, if your existing tropical library gives a bound of the form `|s x' i - s x i| ≤ L * ‖x'-x‖∞`, use that directly. The key combinatorial theorem only needs a bound

```lean
∀ i, |s x' i - s x i| ≤ ε
```

for some perturbation budget `ε`. Then the tropical/GL3-specific corollary instantiates `ε := K * r` or `ε := K * d * r`, depending on the previously established norm conversion.

So prove the abstract theorem first with a generic `ε`, then derive the certified robustness corollary with the explicit tropical radius.

---

### 4. Main abstract elimination-order stability theorem

A central theorem should have the following shape:

```lean
theorem eliminationOrder_stable_of_gap_certificate
    {m : ℕ}
    {v v' : Fin m → ℝ}
    {S : Finset (Fin m)} (hS : S.Nonempty)
    {ε γ : ℝ}
    (hcert : EliminationGapCertified S hS v γ)
    (hε : 0 ≤ ε)
    (hgap : 2 * ε < γ)
    (hclose : ∀ i, |v' i - v i| ≤ ε) :
    eliminationOrderOn S hS v' = eliminationOrderOn S hS v
```

This is the clean inductive theorem. The proof is by induction on `S.card`.

At the key induction step:
1. Let `i` be the first loser for `v` on `S`.
2. From `HasGapAtLeast S v i γ` and `|v'-v| ≤ ε`, prove for every `j ≠ i` in `S`:
   ```lean
   v' i + (γ - 2 * ε) ≤ v' j
   ```
   hence `v' i < v' j` using `2*ε < γ`.
3. Conclude that `i` is also the unique loser for `v'` on `S`.
4. Erase `i` from `S`, restrict the same coordinatewise perturbation bound to the remaining set, and apply the induction hypothesis to the recursive certificate on `S.erase i`.

A useful local lemma is:

```lean
lemma gap_preserved_under_uniform_perturbation
    {m : ℕ} {S : Finset (Fin m)} {v v' : Fin m → ℝ}
    {i : Fin m} {γ ε : ℝ}
    (hgap : HasGapAtLeast S v i γ)
    (hclose : ∀ k, |v' k - v k| ≤ ε) :
    ∀ j ∈ S, j ≠ i → v' i + (γ - 2 * ε) ≤ v' j
```

This is just the triangle inequality arranged as
`v' j - v' i = (v' j - v j) + (v j - v i) + (v i - v' i)`.

A second useful lemma is uniqueness of the minimizer from a positive preserved gap:

```lean
lemma unique_roundLoser_of_positive_gap
    {m : ℕ} {S : Finset (Fin m)} {v : Fin m → ℝ} {i : Fin m} {δ : ℝ}
    (hδ : 0 < δ)
    (hsep : ∀ j ∈ S, j ≠ i → v i + δ ≤ v j) :
    roundLoser S v = i
```

This isolates the finite argmin reasoning from the perturbation algebra.

---

### 5. Winner stability as a corollary

Once elimination-order stability is proved, the winner theorem should be immediate:

```lean
theorem irvWinner_stable_of_gap_certificate
    {m : ℕ}
    {v v' : Fin m → ℝ}
    {S : Finset (Fin m)} (hS : S.Nonempty)
    {ε γ : ℝ}
    (hcert : EliminationGapCertified S hS v γ)
    (hε : 0 ≤ ε)
    (hgap : 2 * ε < γ)
    (hclose : ∀ i, |v' i - v i| ≤ ε) :
    irvWinnerOn S hS v' = irvWinnerOn S hS v
```

Then specialize to `S = Finset.univ`:

```lean
theorem irvWinner_stable_univ_of_gap_certificate
    {m : ℕ}
    {v v' : Fin m → ℝ}
    {ε γ : ℝ}
    (hm : 0 < m)
    (hcert : EliminationGapCertified Finset.univ (Finset.univ_nonempty) v γ)
    (hε : 0 ≤ ε)
    (hgap : 2 * ε < γ)
    (hclose : ∀ i, |v' i - v i| ≤ ε) :
    irvWinner v' = irvWinner v
```

The point is that this theorem is purely combinatorial and can be reused for any multiclass score architecture, not only tropical GL3.

---

### 6. Tropical/GL3 certified robustness corollary

Now derive the intended geometric robustness theorem for a score map `s`.

A precise target statement is:

```lean
theorem irvWinner_certified_robust
    {d m : ℕ}
    (s : (Fin d → ℝ) → Fin m → ℝ)
    {x x' : Fin d → ℝ}
    {r K γ : ℝ}
    (hLip : ∀ z z', (∀ k, |z' k - z k| ≤ r) → ∀ i, |s z' i - s z i| ≤ K * r)
    (hpert : ∀ k, |x' k - x k| ≤ r)
    (hK : 0 ≤ K)
    (hr : 0 ≤ r)
    (hcert : EliminationGapCertified Finset.univ (Finset.univ_nonempty)
      (fun i => s x i) γ)
    (hmargin : 2 * (K * r) < γ) :
    irvWinner (fun i => s x' i) = irvWinner (fun i => s x i)
```

If your tropical score bounds naturally produce `|s x' i - s x i| ≤ K * d * r`, replace `K * r` by `K * d * r` everywhere. Do not hide this in prose; make the exact arithmetic constant explicit in the theorem statement. If the existing catalog gives a theorem with a different norm convention, derive the exact scalar conversion lemma once and reuse it.

A stronger, more practical theorem separates full elimination-order stability from mere winner stability. The winner may remain unchanged even if some noncritical early-round ordering changes. To capture this, define a certificate only along the realized elimination path of `v = s x`:

```lean
def WinnerPathCertified {m : ℕ} (v : Fin m → ℝ) (γ : ℝ) : Prop := ...
```

requiring only the margins needed to ensure that the eventual winner is never eliminated under perturbation. Then prove:

```lean
theorem irvWinner_stable_of_winner_path_certificate
    {m : ℕ} {v v' : Fin m → ℝ} {ε γ : ℝ}
    (hpath : WinnerPathCertified v γ)
    (hgap : 2 * ε < γ)
    (hclose : ∀ i, |v' i - v i| ≤ ε) :
    irvWinner v' = irvWinner v
```

This is mathematically stronger and better aligned with certification practice: complete ranking stability is sufficient but not necessary for winner stability.

---

### 7. Concrete proof strategy

Use the following proof architecture.

1. **Finite unique-minimizer machinery.**  
   Prove that if `S` is nonempty and all scores on `S` are pairwise distinct, then there is a unique `i ∈ S` minimizing `v`. Implement this either through `Finset.argmin`-style lemmas or by choosing the loser from the finite set with a proof of uniqueness. Isolate these existence/uniqueness lemmas so the recursive elimination definition is not cluttered.

2. **One-round perturbation lemma.**  
   From `HasGapAtLeast S v i γ` and uniform coordinatewise perturbation `|v'-v| ≤ ε`, derive the preserved strict separation
   ```lean
   ∀ j ∈ S, j ≠ i → v' i < v' j
   ```
   whenever `2*ε < γ`. This is the algebraic heart of the proof. Expect to use `abs_sub_le_iff` or two inequalities extracted from `|a| ≤ ε`.

3. **Induction on active-set cardinality.**  
   Prove elimination-order stability by induction on `S.card`. Base case `card = 1` is immediate. In the step, show the same first loser under perturbation, erase it from both processes, and apply the induction hypothesis to the tail. The recursive certificate `EliminationGapCertified` is designed exactly to make this induction straightforward.

4. **Winner corollary.**  
   Deduce equality of winners from equality of elimination orders, or directly by recursion if your winner is defined independently of the full list.

5. **Instantiate with tropical score bounds.**  
   Apply the abstract theorem to `v i = s x i`, `v' i = s x' i`, and `ε = K*r` or the exact available bound. This should be a short final wrapper theorem.

---

### 8. Significance

This theorem gives a genuinely new robustness principle for multiclass decision procedures whose output is not a simple argmax but a recursive social-choice-style elimination rule. The mathematical content is the bridge between:
- **tropical / GL3 Satake score geometry**, which controls score perturbations analytically via Lipschitz bounds, and
- **instant-runoff combinatorics**, where the prediction depends on an iterated sequence of discrete eliminations.

What makes this nontrivial is that robustness of each score coordinate does **not** automatically imply robustness of the elimination process: one must show that the entire recursive elimination tree is stable. Formalizing this yields a reusable certification theorem for any sequential-elimination classifier with piecewise-linear tropical score maps. It also creates the right infrastructure for later extensions:
- weighted or partial-transfer runoff schemes,
- top-`k` elimination procedures,
- stronger winner-only certificates,
- and eventual comparison with other multiclass aggregators such as ECOC, Condorcet-style, or Kemeny–Young variants.

A successful formalization here would therefore advance the tropical certified-robustness program from static score comparison to recursive combinatorial decision rules, which is exactly the next conceptual step.

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Bridges
Research mode: prove
