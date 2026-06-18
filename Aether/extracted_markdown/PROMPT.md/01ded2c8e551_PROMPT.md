You are formalizing a self-contained theory of clique complexes, flag complexes, and the Vietoris-Rips filtration in Lean 4 (using Mathlib).

## Definitions to set up

1. **SimpleGraph α** (use Mathlib's): a graph on a type α with a symmetric irreflexive adjacency relation.
2. **ASC (AbstractSimplicialComplex) α**: a set of Finsets α that is downward-closed and closed under taking vertices. Define this as a structure with a field `faces : Set (Finset α)` satisfying: (a) ∀ s ∈ faces, ∀ t ⊆ s, t ∈ faces (downward-closed), (b) ∀ a, {a} ∈ faces (contains all singletons — we will later show this can be dropped for clique complexes but not for flag complexes in general).
3. **isClique (G : SimpleGraph α) (S : Finset α)**: every pair of distinct vertices in S is adjacent. Formalize as: S ⊆ G.vertexSet ∧ ∀ x ∈ S, ∀ y ∈ S, x ≠ y → G.Adj x y.
4. **cliqueComplex (G : SimpleGraph α)**: the ASC whose faces are exactly the cliques of G. Define: `{ S | isClique G S }` with proofs of downward-closure and singletons.
5. **isFlag (K : ASC α)**: K is downward-closed (already in the definition) AND every complete subgraph of the one-skeleton that has k vertices spans a (k-1)-face. Formalize as: ∀ S, (∀ x ∈ S, ∀ y ∈ S, x ≠ y → oneSkel K).Adj x y → S ∈ K.faces. Note: oneSkel K extracts the graph of 1-faces.
6. **oneSkel (K : ASC α) : SimpleGraph α**: the graph whose adjacency is: G.Adj x y ↔ {x,y} ∈ K.faces ∧ x ≠ y.
7. **vietorisRips (ε : ℕ) (d : α → α → ℕ) : ASC α**: the VR complex at scale ε, containing all finsets S where max distance between pairs is ≤ ε.
8. **fVector (K : ASC α) : ℕ → ℕ**: f k = |{s ∈ K.faces | s.card = k+1}|.

## Theorems to prove (with COMPLETE proof bodies)

### Theorem 1: isClique_pair
A two-element set {a,b} is a clique iff a and b are adjacent.
`theorem isClique_pair {G : SimpleGraph α} {a b : α} (ha : a ∈ G.vertexSet) (hb : b ∈ G.vertexSet) : isClique G {a,b} ↔ G.Adj a b`

### Theorem 2: cliqueComplex_isFlag
Every clique complex is a flag complex.
`theorem cliqueComplex_isFlag (G : SimpleGraph α) : isFlag (cliqueComplex G)`
Proof sketch: Let S be a set where every pair is adjacent in oneSkel (cliqueComplex G). Then every pair in S is a clique of G (by isClique_pair). So S itself is a clique of G, hence S ∈ (cliqueComplex G).faces.

### Theorem 3: oneSkeleton_cliqueComplex
The one-skeleton of Δ(G) is exactly G.
`theorem oneSkeleton_cliqueComplex (G : SimpleGraph α) : oneSkel (cliqueComplex G) = G`

### Theorem 4: flag_eq_cliqueComplex
Every flag complex containing all singletons is the clique complex of its one-skeleton.
`theorem flag_eq_cliqueComplex {K : ASC α} (hFlag : isFlag K) (hSing : ∀ a, ({a} : Finset α) ∈ K.faces) : K = cliqueComplex (oneSkel K)`
Proof sketch: By extensionality on the face sets. Forward: if S ∈ K.faces, then by downward-closure all pairs in S are edges of oneSkel K, so S is a clique of oneSkel K. Backward: if S is a clique of oneSkel K, then every pair in S is adjacent in oneSkel K, so by the flag property, S ∈ K.faces.

### Theorem 5: flag_not_cliqueComplex_without_singletons (Counterexample)
The singleton hypothesis cannot be dropped. Exhibit the flag complex K = {∅} on Bool.
`theorem flag_not_cliqueComplex_without_singletons : ∃ (K : ASC Bool), isFlag K ∧ K ≠ cliqueComplex (oneSkel K)`
Proof: K = {∅} is a flag complex (vacuously), but cliqueComplex (oneSkel K) = cliqueComplex ⊥ contains singletons, so K ≠ cliqueComplex (oneSkel K).

### Theorem 6: vietorisRips_mono
The Vietoris-Rips complex is monotone in scale.
`theorem vietorisRips_mono {ε₁ ε₂ : ℕ} (d : α → α → ℕ) (h : ε₁ ≤ ε₂) : vietorisRips ε₁ d ≤ vietorisRips ε₂ d`

### Theorem 7: cliqueComplex_fVector_le_choose
Turán-style bound: f_k(Δ(G)) ≤ C(n, k+1).
`theorem cliqueComplex_fVector_le_choose (G : SimpleGraph α) [Fintype α] (k : ℕ) : fVector (cliqueComplex G) k ≤ (Fintype.card α).choose (k + 1)`

## Important constraints
- Every theorem MUST have a complete proof body (`:= by ...`).
- Do NOT use `sorry` anywhere.
- Do NOT leave proof bodies empty.
- The file MUST compile in Lean 4 with Mathlib.
- Focus on theorems 1-5 (the equivalence) as the core result; theorems 6-7 are secondary.
- Use `Finset` and `SimpleGraph` from Mathlib wherever possible.
- For the counterexample (theorem 5), use `Bool` as the vertex type and construct the empty complex explicitly.