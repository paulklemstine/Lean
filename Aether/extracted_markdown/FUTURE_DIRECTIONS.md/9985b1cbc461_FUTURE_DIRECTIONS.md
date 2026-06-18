# Future Directions: Tropical Causal Ordering

## 1. Tropical Lorentzian Geometry: Causal Cones and Light-Cone Structure

**Theorem target**: Define tropical causal cones and prove that the one-sided displacement preorder on `Fin n → ℝ` admits a natural cone structure analogous to future light-cones in Lorentzian geometry.

```
def TropicalCausalCone (x : Fin n → ℝ) (T : ℝ) : Set (Fin n → ℝ) :=
  { y | TropicalCausal tropicalOneSidedDisplacement T x y }

theorem causal_cone_nested (x : Fin n → ℝ) {T₁ T₂ : ℝ} (h : T₁ ≤ T₂) :
    TropicalCausalCone x T₁ ⊆ TropicalCausalCone x T₂

theorem causal_cone_convex (x : Fin n → ℝ) (T : ℝ) :
    Convex ℝ (TropicalCausalCone x T)
```

**Lean definitions needed**: `TropicalCausalCone`, tropical convexity predicates, cone algebra operations.

**Proof strategy**: The nested cone property follows from monotonicity of the budget parameter. Convexity requires showing that if `max_i (y_i - x_i) ≤ T` and `max_i (z_i - x_i) ≤ T`, then for `0 ≤ t ≤ 1`, `max_i (t·y_i + (1-t)·z_i - x_i) ≤ T`, which follows from the max of convex combinations being bounded by the max of the individual terms.

**Cross-domain significance**: This would establish tropical geometry as a legitimate framework for causal structure theory, connecting min-plus algebra to the causal hierarchy in mathematical physics. The tropical causal cone would serve as the combinatorial skeleton of Lorentzian light-cones, potentially enabling discrete approximations to spacetime causality for computation.

---

## 2. Tropical Reachability Algebras: Floyd–Warshall as Causal Closure

**Theorem target**: Prove that the tropical matrix power `A^⊗k` computes k-hop causal reachability, and that the Kleene star `A* = ⊕_{k=0}^{n-1} A^⊗k` gives the transitive closure of matrix causality.

```
def tropMatPow (A : Matrix (Fin n) (Fin n) ℝ) : ℕ → Matrix (Fin n) (Fin n) ℝ
  | 0 => tropId n 0
  | k + 1 => tropMatMul A (tropMatPow A k)

def tropicalKleeneStar (A : Matrix (Fin n) (Fin n) ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  fun i j => Finset.univ.inf' ... (fun k => tropMatPow A k i j)

theorem kleene_star_is_causal_closure (A : Matrix (Fin n) (Fin n) ℝ) (i j : Fin n) :
    (∃ T, MatrixCausal A T i j) ↔ tropicalKleeneStar A i j < ⊤
```

**Lean definitions needed**: `tropMatPow`, `tropicalKleeneStar`, connection lemmas between matrix powers and path costs.

**Proof strategy**: By induction on k, show `tropMatPow A k i j` equals the minimum cost of k-hop paths from i to j. Then the infimum over all k gives the all-pairs shortest path, which equals the Floyd–Warshall closure. Finiteness of the closure is equivalent to the existence of a finite-cost path.

**Cross-domain significance**: This connects tropical causality to algorithmic graph theory and dynamic programming. The Floyd–Warshall algorithm becomes a causal closure operator, and min-plus matrix multiplication becomes causal composition. This opens tropical verification of shortest-path algorithms and network routing protocols.

---

## 3. Tropical Neural Network Causal Certificates

**Theorem target**: For a tropical (max-plus) neural network with layer maps `f₁, ..., f_L`, prove that if each layer is nonexpansive with Lipschitz constant `≤ 1`, then the entire network preserves the causal preorder, and adversarial perturbation budgets compose additively across layers.

```
def TropicalNetwork (layers : List (Fin n → ℝ → Fin n → ℝ)) := ...

theorem network_causal_certificate
    (net : TropicalNetwork layers)
    (h_nonexp : ∀ l ∈ layers, TropicalNonexpansive τ τ l)
    {x y : Fin n → ℝ} (hxy : TropicalFuture τ x y) :
    TropicalFuture τ (net.eval x) (net.eval y)

theorem adversarial_budget_composition
    (net : TropicalNetwork layers)
    (budgets : List ℝ)
    (h_layer_budgets : ∀ i x, TropicalCausal τ (budgets[i]) x (layers[i] x)) :
    TropicalCausal τ (budgets.sum) x (net.eval x)
```

**Lean definitions needed**: `TropicalNetwork`, `eval` function, layer-wise Lipschitz bounds.

**Proof strategy**: Induction on the number of layers, using `tropicalNonexpansive_comp` and `tropical_causal_transitive_budget` at each step. The key insight is that causal budget composition is precisely the mechanism behind certified robustness radii.

**Cross-domain significance**: This would be the first formal framework where neural network robustness certificates are derived from causal order theory rather than ad hoc Lipschitz analysis. It unifies adversarial robustness, tropical geometry, and order theory into a single compositional framework.

---

## 4. Tropical Spectral Causality: Eigenpairs as Invariant Causal Directions

**Theorem target**: Prove that a tropical eigenvector of a min-plus matrix defines a causal invariant ray — a direction along which the causal preorder is preserved by the matrix action.

```
theorem eigenvector_causal_invariance
    {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ)
    (d : ℝ) (v : Fin n → ℝ) (heig : IsTropicalEigenpair A d v) :
    ∀ t : ℝ, 0 ≤ t →
      TropicalCausal (fun x y => tropicalSupDisplacement (tropMatVecMul A x) (tropMatVecMul A y))
        (t * |d|)
        (fun i => v i) (fun i => v i + t)

theorem eigenpair_preserves_future
    {n : ℕ} [NeZero n] (A : Matrix (Fin n) (Fin n) ℝ)
    (d : ℝ) (v : Fin n → ℝ) (heig : IsTropicalEigenpair A d v) (hd : d ≤ 0) :
    TropicalFuture (fun x y => tropicalOneSidedDisplacement (tropMatVecMul A x) (tropMatVecMul A y))
      v v
```

**Lean definitions needed**: Connection between `IsTropicalEigenpair` and the causal displacement functionals. Tropical ray definitions.

**Proof strategy**: From the eigenpair equation `A ⊗ v = d ⊕ v` (in min-plus notation), derive that shifting v by a constant preserves the action up to the eigenvalue shift. When d ≤ 0, the eigenvalue acts as a contraction, preserving the future cone.

**Cross-domain significance**: This connects tropical spectral theory to causal dynamics. In min-plus systems (scheduling, manufacturing, discrete-event simulation), the eigenvalue determines the cycle time, and the eigenvector defines the steady-state timing. The causal invariance theorem would show that steady-state timing respects the causal ordering — a fundamental consistency property for discrete-event systems.

---

## 5. Tropical Entropy and Causal Information Flow

**Theorem target**: Define a notion of causal information capacity using tropical entropy, and prove that nonexpansive maps cannot increase causal information flow.

```
def tropicalCausalEntropy (τ : α → α → ℝ) (S : Finset α) (T : ℝ) : ℝ :=
  Finset.log (S.filter (fun y => ∃ x ∈ S, TropicalCausal τ T x y)).card

theorem causal_entropy_nonincreasing
    {α β : Type*} {τ₁ : α → α → ℝ} {τ₂ : β → β → ℝ} {f : α → β}
    (hf : TropicalNonexpansive τ₁ τ₂ f)
    (S : Finset α) (T : ℝ) :
    tropicalCausalEntropy τ₂ (S.image f) T ≤ tropicalCausalEntropy τ₁ S T

theorem security_from_causal_entropy
    (τ : α → α → ℝ) (S : Finset α) (T : ℝ) :
    tropicalCausalEntropy τ S T ≤ Finset.log S.card
```

**Lean definitions needed**: `tropicalCausalEntropy`, connection to `tropicalEntropy` from the existing catalog, image-based entropy bounds.

**Proof strategy**: The key insight is that nonexpansive maps cannot create new causal links (by `tropical_future_monotone_of_nonexpansive`), so the set of causally reachable points in the image is a subset of the image of causally reachable points. Cardinality bounds follow from injectivity arguments.

**Cross-domain significance**: This would create a tropical analogue of the data processing inequality from information theory. It connects tropical causality to channel capacity, cryptographic security (the size of the causal future bounds the key search space), and network information flow. Combined with `tropical_security_from_norm_bound`, this gives a unified framework for analyzing information-theoretic security through causal geometry.
