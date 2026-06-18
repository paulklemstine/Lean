
            ## PHASE A: LEAN 4 ONLY — DOING THE MATH

            You are a world-class mathematician. Your ONLY job in this cycle is
to produce **new Lean 4 code that extends the frontier of mathematics**.

            ### DELIVERABLES (strict — only this):
            1. **lean files (count chosen by the Plan)**
            2. **2-4 theorems with correct proofs (sorry = 0 on main results)**
            3. **Brief proof sketches** as `-- !-- comment -- !--` blocks (1-2 sentences each)
            4. **A FUTURE_DIRECTIONS.md file** listing 3-5 testable, falsifiable
               conjectures as a freeform narrative (NOT a form). Each direction MUST
               include a "The key insight is..." sentence and a "Why now?" justification.
               This file drives the next research cycle — make it count.

            ### DO NOT OUTPUT (Phase B handles these — if your work passes quality bar):
            - NO `ARTICLE.md`
            - NO `RESEARCH_PAPER.md`
            - NO `demo.py` / `algorithms.py`
            - NO HTML widgets
            - NO `PACKAGE.json`
            - NO prose for human readers (except FUTURE_DIRECTIONS.md)

            ### WHY THIS NARROW:
            The Lean 4 file IS the deliverable. A self-contained Lean file with
            3-5 world-class theorems is worth more than 30K characters of prose
            about trivial results. Focus 100% of your compute on the math.
            If your work is genuinely world-class, the packaging step is dispatched
            automatically and cheaply.


## Concept

**Title**: The clique complex Δ(G) admits a natural chain complex over ℤ: the k-th chain gr
**Domain**: Shared
**Mathematical framing**: # Future Directions: Clique Complex Theory in Lean 4

## 1. Homology of Clique Complexes via Chain Complexes

The clique complex Δ(G) admits a natural chain complex over ℤ: the k-th chain group is the free abelian group on k-faces, and the boundary maps are the standard simplicial boundary operators. Computing the homology groups H_k(Δ(G); ℤ) would unlock Betti numbers β_k and the full power of persistent homology.

The key insight is that Mathlib already has `HomologicalComplex` and `homology` functors — the missing piece is constructing the simplicial boundary map ∂_k : C_k → C_{k-1} from our `ASC` type, which requires formalizing signed face maps (alternating sums of face deletions). This would connect our combinatorial definitions directly to Mathlib's homological algebra.

Why now? The `ASC` structure and face-counting machinery are in place. The boundary map is the single construction needed to bridge combinatorial topology and homological algebra in Lean 4. No existing Lean formalization has done this.

## 2. Vietoris-Rips Filtrations and Persistent Homology

Given a finite metric space (X, d) and a scale parameter ε, the Vietoris-Rips complex VR(X, ε) is the clique complex of the graph where vertices within distance ε are adjacent. As ε grows from 0 to ∞, this yields a filtration of simplicial complexes ∅ ⊆ VR(X, ε₁) ⊆ VR(X, ε₂) ⊆ ⋯ ⊆ Δ(K_n).

The key insight is that our monotonicity theorem (`cliqueComplex_mono`) already proves that subgraph inclusion induces subcomplex inclusion. Formalizing the threshold graph G_ε (where `G.Adj u v ↔ d u v ≤ ε`) and proving that ε₁ ≤ ε₂ implies G_{ε₁} ≤ G_{ε₂} would give the first verified persistent homology pipeline.

Why now? The monotonicity infrastructure is complete. The remaining step is a clean formalization of threshold graphs from metric spaces, which is combinatorially straightforward.

## 3. Turán-Type Bounds on Face Numbers

Our `cliqueComplex_fVector_le_choose` shows f_k(Δ(G)) ≤ C(n, k+1), but this bound is tight only for complete graphs. For graphs with bounded clique number ω(G) ≤ r, the Kruskal-Katona theorem gives much sharper bounds on face numbers. In particular, f_k = 0 for all k ≥ r.

The key insight is that Turán's theorem (the extremal graph with no (r+1)-clique is the complete r-partite graph) should translate directly into sharp bounds on the f-vector of clique complexes: the Turán graph T(n,r) maximizes f_k among all graphs with ω(G) ≤ r, and its face counts are computable.

Why now? Turán's theorem has been partially formalized in Lean/Mathlib. Connecting it to our clique complex f-vector would create a novel bridge between extremal graph theory and combinatorial topology.

## 4. Garland's Method: Spectral Gaps Force Vanishing Homology

Garland's 1973 theorem states: if every link of a vertex in a simplicial complex has spectral gap λ₁ > 1/(k+1), then H_k(K; ℝ) = 0. This gives a purely graph-theoretic criterion (eigenvalues of adjacency matrices of links) for vanishing of homology groups.

The key insight is that this would be the first formalized connection between spectral graph theory and simplicial homology. The link of a vertex v in our clique complex is itself a clique complex (of the neighborhood graph of v), so the definition infrastructure is already in place.

Why now? Mathlib has spectral theory for matrices (`Matrix.IsHermitian`, eigenvalue bounds). Our ASC definition naturally supports extracting vertex links. The gap is formalizing the Garland inequality itself, which requires the Laplacian of the chain complex.

## 5. Random Clique Complexes: Phase Transitions in Betti Numbers

For the Erdős-Rényi random graph G(n, p), the expected number of k-faces in Δ(G(n,p)) is C(n, k+1) · p^{C(k+1,2)}. Kahle (2009) proved sharp thresholds: β_k peaks near p ≈ n^{-1/(k+1)} and the transition width shrinks as n → ∞. The original conjecture that β_k ≈ n^{k+1} corresponds to this peak regime.

The key insight is that the face-counting formula is deterministic and verifiable now — our `cliqueComplex_complete_fVector` gives the upper bound, and the expected value computation is a direct product formula. Formalizing the expected f-vector of random clique complexes would be the first step toward verified probabilistic topology.

Why now? The f-vector machinery is complete. Computing E[f_k] = C(n,k+1) · p^{C(k+1,2)} requires only our existing face count combined with independence of edge events, which is accessible in probability theory.

**Concept description**: # Future Directions: Clique Complex Theory in Lean 4

## 1. Homology of Clique Complexes via Chain Complexes

The clique complex Δ(G) admits a natural chain complex over ℤ: the k-th chain group is the free abelian group on k-faces, and the boundary maps are the standard simplicial boundary operators. Computing the homology groups H_k(Δ(G); ℤ) would unlock Betti numbers β_k and the full power of persistent homology.

The key insight is that Mathlib already has `HomologicalComplex` and `homology` functors — the missing piece is constructing the simplicial boundary map ∂_k : C_k → C_{k-1} from our `ASC` type, which requires formalizing signed face maps (alternating sums of face deletions). This would connect our combinatorial definitions directly to Mathlib's homological algebra.

Why now? The `ASC` structure and face-counting machinery are in place. The boundary map is the single construction needed to bridge combinatorial topology and homological algebra in Lean 4. No existing Lean formalization has done this.

## 2. Vietoris-Rips Filtrations and Persistent Homology

Given a finite metric space (X, d) and a scale parameter ε, the Vietoris-Rips complex VR(X, ε) is the clique complex of the graph where vertices within distance ε are adjacent. As ε grows from 0 to ∞, this yields a filtration of simplicial complexes ∅ ⊆ VR(X, ε₁) ⊆ VR(X, ε₂) ⊆ ⋯ ⊆ Δ(K_n).

The key insight is that our monotonicity theorem (`cliqueComplex_mono`) already proves that subgraph inclusion induces subcomplex inclusion. Formalizing the threshold graph G_ε (where `G.Adj u v ↔ d u v ≤ ε`) and proving that ε₁ ≤ ε₂ implies G_{ε₁} ≤ G_{ε₂} would give the first verified persistent homology pipeline.

Why now? The monotonicity infrastructure is complete. The remaining step is a clean formalization of threshold graphs from metric spaces, which is combinatorially straightforward.

## 3. Turán-Type Bounds on Face Numbers

Our `cliqueComplex_fVector_le_choose` shows f_k(Δ(G)) ≤ C(n, k+1), but this bound is tight only for complete graphs. For graphs with bounded clique number ω(G) ≤ r, the Kruskal-Katona theorem gives much sharper bounds on face numbers. In particular, f_k = 0 for all k ≥ r.

The key insight is that Turán's theorem (the extremal graph with no (r+1)-clique is the complete r-partite graph) should translate directly into sharp bounds on the f-vector of clique complexes: the Turán graph T(n,r) maximizes f_k among all graphs with ω(G) ≤ r, and its face counts are computable.

Why now? Turán's theorem has been partially formalized in Lean/Mathlib. Connecting it to our clique complex f-vector would create a novel bridge between extremal graph theory and combinatorial topology.

## 4. Garland's Method: Spectral Gaps Force Vanishing Homology

Garland's 1973 theorem states: if every link of a vertex in a simplicial complex has spectral gap λ₁ > 1/(k+1), then H_k(K; ℝ) = 0. This gives a purely graph-theoretic criterion (eigenvalues of adjacency matrices of links) for vanishing of homology groups.

The key insight is that this would be the first formalized connection between spectral graph theory and simplicial homology. The link of a vertex v in our clique complex is itself a clique complex (of the neighborhood graph of v), so the definition infrastructure is already in place.

Why now? Mathlib has spectral theory for matrices (`Matrix.IsHermitian`, eigenvalue bounds). Our ASC definition naturally supports extracting vertex links. The gap is formalizing the Garland inequality itself, which requires the Laplacian of the chain complex.

## 5. Random Clique Complexes: Phase Transitions in Betti Numbers

For the Erdős-Rényi random graph G(n, p), the expected number of k-faces in Δ(G(n,p)) is C(n, k+1) · p^{C(k+1,2)}. Kahle (2009) proved sharp thresholds: β_k peaks near p ≈ n^{-1/(k+1)} and the transition width shrinks as n → ∞. The original conjecture that β_k ≈ n^{k+1} corresponds to this peak regime.

The key insight is that the face-counting formula is deterministic and verifiable now — our `cliqueComplex_complete_fVector` gives the upper bound, and the expected value computation is a direct product formula. Formalizing the expected f-vector of random clique complexes would be the first step toward verified probabilistic topology.

Why now? The f-vector machinery is complete. Computing E[f_k] = C(n,k+1) · p^{C(k+1,2)} requires only our existing face count combined with independence of edge events, which is accessible in probability theory.

**Novelty estimate**: 0.75
**Breakthrough potential**: 0.75
Research domain: Shared
Research mode: team




### Recent Discoveries in Catalog
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.


## v7 Depth Requirements — Structured Proofs with Completeness Gates

You are producing Lean 4 code on the mathematical frontier. Your output must
be COMPILABLE and your proofs must be COMPLETE. A single correct proof of a
non-trivial result is worth more than 5 theorems with `sorry`.

### STEP 1: THEOREM DECLARATIONS (required — before any code)

List every theorem you intend to prove. For each, state:
- **Name**: The Lean declaration name
- **Statement**: One-sentence informal statement
- **Status**: `proved` | `conjecture` | `proved_with_lemma_sorry`
- **Why non-trivial**: One sentence on the key mathematical insight

Example:
1. `cantorPairing_surjective`: Cantor pairing is surjective — proved — constructive inverse
2. `cantorPairing_injective`: Cantor pairing is injective — proved — diagonal argument
3. `cantorPairing_bijection`: Cantor pairing is a bijection — proved_with_lemma_sorry — follows from 1+2

### STEP 2: PROVE THEOREMS (completeness gate)

Every theorem declared as `proved` MUST have a complete, compiling Lean proof.
No `sorry` on the main result. If you cannot complete a proof, change its status
to `conjecture` or `proved_with_lemma_sorry` and explain why.

For `proved_with_lemma_sorry`:
- The theorem statement must be complete (no sorry in the statement)
- `sorry` is allowed ONLY in supporting lemmas, never the main proof
- A comment must explain what the sorry replaces and why it's deferred

For your BEST theorem, also provide:
- A generalization or strengthening (can use sorry if proving would take too long)
- A boundary case or counterexample showing where the result fails

### STEP 3: Anti-patterns (reject these)

These tactics indicate trivial proofs:
- `native_decide` / `decide` / `norm_num` / `rfl` — unless genuinely proving a numeric fact
- `simp only []` with no simp set specified
- `sorry` on any theorem declared as `proved`

`omega`, `linarith`, and `Aesop` are fine for supporting lemmas.
`sorry` is fine for conjectures and generalizations.

### STEP 4: Novelty

Your theorems must be genuinely new. If a statement appears in a textbook,
generalize it. If you cannot formalize a concept rigorously, pick a different topic.

### Output format

Your output must include:
1. `.lean` files with the proofs (structured as declared in Step 1)
2. `FUTURE_DIRECTIONS.md` with 3-5 research conjectures extending the work

Both are required. Missing FUTURE_DIRECTIONS.md = automatic quality penalty.


## Output format reminder

Your output must include `.lean` files AND a `FUTURE_DIRECTIONS.md` file.
The .lean files contain the proofs. The FUTURE_DIRECTIONS.md contains 3-5
research conjectures that extend the work. Both are required.
Be precise, be deep, be world-class.
