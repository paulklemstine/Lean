# Future Directions: Idempotent Representer Theory

The representer theorem formalized in `MaxPlusRepresenter.lean` opens several concrete avenues for further formalization and application. Below are five specific next targets, each stated as a precise theorem-level goal.

---

## 1. Tropical Ridge Representer with Explicit Coefficient Solver

**Goal**: For the tropical ridge regularizer `reg(f) = max_{x ∈ train} c(x)` (the ℓ∞ norm of coefficients), the optimal coefficient vector can be characterized explicitly via a tropical linear system.

**Theorem target**:
```lean
theorem tropical_ridge_coefficients
    [LinearOrder α] [OrderBot α] [Add α] [Sub α]
    (K : X → X → α) (train : Finset X)
    (y : X → α) (λ : α)
    (c_opt : X → α)
    (hopt : ∀ x ∈ train, (train.sup fun z => K x z + c_opt z) = y x)
    (hreg : ∀ x, c_opt x ≤ λ) :
    -- c_opt minimizes the tropical ridge objective
    ∀ c : X → α,
      (∀ x ∈ train, (train.sup fun z => K x z + c z) = y x) →
      train.sup c_opt ≤ train.sup c
```

This makes the representer theorem algorithmic: instead of abstract existence, we get a finite tropical linear program whose solution can be computed by Bellman-Ford–style shortest path algorithms in the max-plus semiring.

---

## 2. Duality: Coefficient Optimization as a Residuated Linear Program

**Goal**: Identify the dual of the coefficient-space optimization problem as a residuated linear program, establishing strong duality in the max-plus sense.

**Theorem target**:
```lean
theorem tropical_strong_duality
    [LinearOrder α] [OrderBot α] [OrderTop α] [Add α]
    (K_train : Fin n → Fin n → α)
    (y : Fin n → α) :
    -- Primal: minimize max_i c_i subject to K ⊗ c = y
    -- Dual: maximize min_i (y_i - max_{j≠i} K_{ij} + c_j)
    -- Strong duality: primal optimal = dual optimal
    sorry
```

This connects the representer theorem to tropical convex duality (Cohen-Gaubert-Quadrat) and provides certificates of optimality for tropical regression.

---

## 3. Stability Bounds for Span-Minimizers Under Label Perturbation

**Goal**: Quantify how the optimal span-minimizer changes when training labels are perturbed, giving a tropical analogue of algorithmic stability.

**Theorem target**:
```lean
theorem tropical_stability_bound
    [LinearOrder α] [OrderBot α] [Add α] [Sub α]
    (K : X → X → α) (train : Finset X)
    (y₁ y₂ : X → α)
    (c₁ c₂ : X → α)
    (hopt₁ : IsOptimalCoeff K train y₁ c₁)
    (hopt₂ : IsOptimalCoeff K train y₂ c₂) :
    -- The change in optimal coefficients is bounded by the change in labels
    train.sup (fun x => |c₁ x - c₂ x|) ≤
      train.sup (fun x => |y₁ x - y₂ x|)
```

This provides generalization guarantees for tropical kernel methods, connecting to leave-one-out analysis in the max-plus setting.

---

## 4. Tropical Mercer Decomposition on Finite Spaces

**Goal**: Every positive semidefinite tropical kernel on a finite space admits a tropical spectral decomposition K(x,z) = max_i (φ_i(x) + φ_i(z)), where φ_i are "tropical eigenfunctions."

**Theorem target**:
```lean
theorem tropical_mercer_finite
    [LinearOrder α] [OrderBot α] [Add α]
    (K : Fin n → Fin n → α)
    (hK_sym : ∀ x z, K x z = K z x)
    (hK_psd : IsTropicalPSD K) :
    ∃ (m : ℕ) (φ : Fin m → Fin n → α),
      ∀ x z, K x z = Finset.univ.sup fun i => φ i x + φ i z
```

This would provide the max-plus analogue of the Mercer theorem and connect tropical kernels to tropical principal component analysis.

---

## 5. Max-Plus Margin Classification (Tropical SVM)

**Goal**: Formalize a tropical support vector machine where the margin is defined via max-plus distance and the representer theorem guarantees that the optimal classifier lies in the tropical kernel span.

**Theorem target**:
```lean
def tropicalMargin
    [LinearOrder α] [OrderBot α] [Add α] [Sub α]
    (K : X → X → α) (train : Finset X) (labels : X → Bool)
    (c : X → α) : α :=
  train.inf fun x =>
    let fx := train.sup fun z => K x z + c z
    if labels x then fx else -fx  -- signed margin

theorem tropical_svm_representer
    [LinearOrder α] [OrderBot α] [Add α] [Sub α]
    (K : X → X → α) (train : Finset X) (labels : X → Bool)
    (P : (X → α) → (X → α))
    (hP : IsRepresenterProjection K train (fun f => -(tropicalMargin K train labels ...)) P) :
    -- Maximum margin classifier exists in the kernel span
    (∃ f, IsMaxMargin K train labels f) →
    ∃ g ∈ tropicalSpanOn K train, IsMaxMargin K train labels g
```

This directly connects to robust classification: the max-plus margin is a worst-case (minimax) criterion, and the tropical SVM provides a classifier that is optimal under adversarial perturbation.

---

## Cross-cutting themes

All five directions share a common structure: they exploit the **residuation principle** — the fact that in a complete lattice with an order-preserving operation, every monotone map has a right adjoint (the residual). This is the tropical analogue of the Riesz representation theorem, and it underlies both the representer theorem and its applications.

The formalization infrastructure built in `MaxPlusRepresenter.lean` — especially `IsRepresenterProjection`, `tropicalSpanOn`, and `HasTrainInterpolation` — provides the reusable scaffolding for all five extensions.
