## Research Task: Tropical certified robustness under average-pooling and parallel-sum aggregation in multiclass piecewise-linear networks

Research Mode: PROVE

Prove a compositional robustness theorem extending tropical/ReLU Lipschitz certification from max-plus / residual / concatenation architectures to DAG networks that also contain convex averaging nodes and additive merge nodes.

The central point is that these merge operations are not tropical-max primitives, but they still preserve the envelope/oscillation inequalities needed for a margin certificate because their contribution to perturbation growth is controlled by coefficient-weighted sums of predecessor constants. This should let you push the existing tropical robustness machinery from residual-style networks toward CNN-like average pooling and message-passing / parallel-branch architectures.

### Core formal objects to introduce

Work over concrete Euclidean coordinate spaces `Fin n → ℝ`, with the sup norm realized pointwise.

Use a coordinatewise sup-distance:
```lean
def distInf {n : ℕ} (x y : Fin n → ℝ) : ℝ :=
  ‖x - y‖∞
```
If convenient, avoid introducing a custom norm and state all bounds pointwise:
```lean
∀ i, |f x i - f y i| ≤ K * ε
```
under hypothesis
```lean
∀ k, |x k - y k| ≤ ε.
```
This is often easier in Lean than manipulating `‖·‖∞` directly.

Define a multiclass margin:
```lean
def pairwiseMargin {C : ℕ} (f : (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ) (c : Fin C) : ℝ :=
  sInf {m : ℝ | ∃ j : Fin C, j ≠ c ∧ m = f x c - f x j}
```
But for formal tractability, a finite-min version is better:
```lean
def marginToClass {C d : ℕ} (f : (Fin d → ℝ) → Fin C → ℝ) (x : Fin d → ℝ) (c : Fin C) : ℝ :=
  ((Finset.univ.erase c).inf' (by
      simpa using Finset.card_erase_pos (s := Finset.univ) (Finset.mem_univ c))
    (fun j => f x c - f x j))
```
You may also want the hypothesis
```lean
∀ j : Fin C, j ≠ c → 0 < f x c - f x j
```
instead of working immediately with `argmax`.

Define a pointwise `K`-Lipschitz predicate in the `L∞` sense:
```lean
def IsInfLipschitz {d m : ℕ} (f : (Fin d → ℝ) → Fin m → ℝ) (K : ℝ) : Prop :=
  0 ≤ K ∧
  ∀ x y i, (∀ k, |x k - y k| ≤ 1) → |f x i - f y i| ≤ K
```
This normalized-radius version is awkward for scaling. A better version is:
```lean
def IsInfLipschitzOn {d m : ℕ} (f : (Fin d → ℝ) → Fin m → ℝ) (K : ℝ) : Prop :=
  0 ≤ K ∧
  ∀ x y i, |f x i - f y i| ≤ K * Finset.univ.sup (fun k : Fin d => |x k - y k|)
```
If `Finset.sup` on `ℝ` becomes annoying, use a parameterized perturbation bound:
```lean
def BddPerturbation {d : ℕ} (x y : Fin d → ℝ) (ε : ℝ) : Prop :=
  ∀ k, |x k - y k| ≤ ε
```
and then:
```lean
def HasOscillationBound {d m : ℕ} (f : (Fin d → ℝ) → Fin m → ℝ) (K : ℝ) : Prop :=
  0 ≤ K ∧
  ∀ x y ε i, BddPerturbation x y ε → |f x i - f y i| ≤ K * ε
```

This last formulation is likely the most Lean-friendly and sufficient for the certification theorem.

### Primary theorem statements

#### 1. Additive / convex merge closure for oscillation bounds

Prove the basic closure lemma for weighted sums.

```lean
theorem HasOscillationBound.add
    {d m : ℕ}
    {f g : (Fin d → ℝ) → Fin m → ℝ}
    {Kf Kg : ℝ}
    (hf : HasOscillationBound f Kf)
    (hg : HasOscillationBound g Kg) :
    HasOscillationBound (fun x i => f x i + g x i) (Kf + Kg) := by
```

More generally, the weighted version is the real engine:
```lean
theorem HasOscillationBound.smul_add
    {d m : ℕ}
    {f g : (Fin d → ℝ) → Fin m → ℝ}
    {α β Kf Kg : ℝ}
    (hf : HasOscillationBound f Kf)
    (hg : HasOscillationBound g Kg) :
    HasOscillationBound
      (fun x i => α * f x i + β * g x i)
      (|α| * Kf + |β| * Kg) := by
```

Then derive a finite-sum version for merge nodes with arbitrary branch weights:
```lean
theorem HasOscillationBound.finset_weighted_sum
    {d m ι : ℕ}
    {s : Finset (Fin ι)}
    {F : Fin ι → (Fin d → ℝ) → Fin m → ℝ}
    {w : Fin ι → ℝ}
    {K : Fin ι → ℝ}
    (hF : ∀ a, a ∈ s → HasOscillationBound (F a) (K a)) :
    HasOscillationBound
      (fun x i => ∑ a in s, w a * F a x i)
      (∑ a in s, |w a| * K a) := by
```

The average-pooling corollary should be explicit:
```lean
theorem HasOscillationBound.average_pool
    {d m ι : ℕ}
    {s : Finset (Fin ι)}
    (hs : s.Nonempty)
    {F : Fin ι → (Fin d → ℝ) → Fin m → ℝ}
    {K : Fin ι → ℝ}
    (hF : ∀ a, a ∈ s → HasOscillationBound (F a) (K a)) :
    HasOscillationBound
      (fun x i => (∑ a in s, F a x i) / s.card)
      ((∑ a in s, K a) / s.card) := by
```
A particularly useful uniform-bound corollary:
```lean
theorem HasOscillationBound.average_pool_uniform
    {d m ι : ℕ}
    {s : Finset (Fin ι)}
    (hs : s.Nonempty)
    {F : Fin ι → (Fin d → ℝ) → Fin m → ℝ}
    {K : ℝ}
    (hF : ∀ a, a ∈ s → HasOscillationBound (F a) K) :
    HasOscillationBound
      (fun x i => (∑ a in s, F a x i) / s.card)
      K := by
```
This says convex averaging does not increase the oscillation constant.

#### 2. Coordinatewise max-gap robustness from output oscillation

Prove the margin-to-robustness theorem in a form that only assumes an output oscillation constant.

```lean
theorem robust_of_margin_bound
    {d C : ℕ}
    {f : (Fin d → ℝ) → Fin C → ℝ}
    {K ε : ℝ}
    {x : Fin d → ℝ}
    {c : Fin C}
    (hC : 1 < C)
    (hK : HasOscillationBound f K)
    (hmargin : ∀ j : Fin C, j ≠ c → 2 * K * ε < f x c - f x j)
    {y : Fin d → ℝ}
    (hy : BddPerturbation x y ε) :
    ∀ j : Fin C, j ≠ c → f y c > f y j := by
```

A version using the finite minimum margin is more elegant once the infrastructure is stable:
```lean
theorem robust_of_marginToClass
    {d C : ℕ}
    {f : (Fin d → ℝ) → Fin C → ℝ}
    {K ε : ℝ}
    {x : Fin d → ℝ}
    {c : Fin C}
    (hK : HasOscillationBound f K)
    (hε : 0 ≤ ε)
    (hmargin : 2 * K * ε < marginToClass f x c)
    {y : Fin d → ℝ}
    (hy : BddPerturbation x y ε) :
    ∀ j : Fin C, j ≠ c → f y c > f y j := by
```

This is the certificate theorem in its cleanest finite-class form.

#### 3. Affine/ReLU/skip/merge compositional theorem

You likely do not need to formalize a full DAG syntax immediately. A pragmatic theorem schema is enough: show closure of `HasOscillationBound` under each primitive, then any recursively built network inherits an explicit constant.

Affine maps:
```lean
theorem HasOscillationBound.affine
    {d m : ℕ}
    (A : Matrix (Fin m) (Fin d) ℝ)
    (b : Fin m → ℝ)
    (K : ℝ)
    (hA : ∀ i : Fin m, ∑ j, |A i j| ≤ K) :
    HasOscillationBound (fun x i => ∑ j, A i j * x j + b i) K := by
```
This uses the `∞ → ∞` operator norm upper bound by maximal row `ℓ¹` norm; the theorem above can use a uniform row bound `K` instead of exact operator norm.

ReLU:
```lean
theorem HasOscillationBound.relu
    {d m : ℕ}
    {f : (Fin d → ℝ) → Fin m → ℝ}
    {K : ℝ}
    (hf : HasOscillationBound f K) :
    HasOscillationBound (fun x i => max (f x i) 0) K := by
```

1-Lipschitz skip operator:
```lean
theorem HasOscillationBound.comp_skip
    {d m n : ℕ}
    {f : (Fin d → ℝ) → Fin m → ℝ}
    {S : (Fin m → ℝ) → Fin n → ℝ}
    {K : ℝ}
    (hf : HasOscillationBound f K)
    (hS : ∀ u v i, |S u i - S v i| ≤ Finset.univ.sup (fun k : Fin m => |u k - v k|)) :
    HasOscillationBound (fun x i => S (f x) i) K := by
```
If `Finset.sup` is unpleasant, replace it with a parameterized version:
```lean
(hS : ∀ u v η i, (∀ k, |u k - v k| ≤ η) → |S u i - S v i| ≤ η)
```
This is much easier to use.

Concatenation:
```lean
theorem HasOscillationBound.concat
    {d m n : ℕ}
    {f : (Fin d → ℝ) → Fin m → ℝ}
    {g : (Fin d → ℝ) → Fin n → ℝ}
    {Kf Kg : ℝ}
    (hf : HasOscillationBound f Kf)
    (hg : HasOscillationBound g Kg) :
    HasOscillationBound
      (fun x i : Fin (m + n) =>
        if h : (i : ℕ) < m then
          f x ⟨i, h⟩
        else
          g x ⟨i - m, by ...⟩)
      (max Kf Kg) := by
```
This theorem is optional unless you want a truly syntax-driven compositional result, but it is useful for DAG branch merges.

A recursive “network certificate” theorem can then be stated either for a custom inductive type of architectures or as an existence theorem for any expression built from these constructors:
```lean
theorem network_hasOscillationBound
    (net : Net d C) :
    HasOscillationBound net.eval net.K := by
```
and finally:
```lean
theorem network_certified_radius
    (net : Net d C)
    (x : Fin d → ℝ)
    (c : Fin C)
    (hmargin : ∀ j, j ≠ c → 0 < net.eval x c - net.eval x j) :
    let r := marginToClass net.eval x c / (2 * net.K)
    ∀ y, BddPerturbation x y r → ∀ j, j ≠ c → net.eval y c > net.eval y j := by
```

### Proof strategy

1. **Prove the perturbation algebra for scalar combinations first.**  
   For `smul_add`, expand
   ```lean
   |α * f x i + β * g x i - (α * f y i + β * g y i)|
   ```
   rewrite as
   ```lean
   |α * (f x i - f y i) + β * (g x i - g y i)|
   ```
   and apply `abs_add`, `abs_mul`, and the hypotheses from `HasOscillationBound`. This is the key lemma that makes additive and average merges compatible with the existing margin machinery.

2. **Derive finite-sum and average-pooling by induction on the Finset.**  
   Use `Finset.induction_on` for weighted sums. For average pooling, instantiate weights with `1 / s.card`. You will need `hs : s.Nonempty` to show `(s.card : ℝ) ≠ 0`. The uniform version should conclude with
   ```lean
   (∑ a in s, K) / s.card = K
   ```
   after rewriting by `Finset.card_nsmul` / `Finset.sum_const_nat`.

3. **Prove the margin certificate via the pairwise gap.**  
   For fixed `j ≠ c`, write
   ```lean
   f y c - f y j = (f x c - f x j) + (f y c - f x c) - (f y j - f x j).
   ```
   Then bound
   ```lean
   |f y c - f x c| ≤ K * ε,   |f y j - f x j| ≤ K * ε,
   ```
   so
   ```lean
   f y c - f y j ≥ (f x c - f x j) - 2 * K * ε.
   ```
   If the margin is strictly larger than `2*K*ε`, conclude positivity. This is exactly why the certified radius is `margin / (2K)`.

4. **Show primitive closure for affine maps and ReLU.**  
   For affine maps, the essential point is
   ```lean
   |∑ j, A i j * (x j - y j)| ≤ ∑ j, |A i j| * |x j - y j| ≤ (∑ j, |A i j|) * ε ≤ K * ε.
   ```
   This gives an explicit, computable global constant via rowwise absolute sums.  
   For ReLU, use the scalar inequality
   ```lean
   |max a 0 - max b 0| ≤ |a - b|
   ```
   coordinatewise. If this lemma is not already in Mathlib in a convenient form, prove it by case splitting on `a ≤ 0`, `b ≤ 0`.

5. **Package the global constant recursively.**  
   The significance of the result is not just local Lipschitzness; it is that the constant is assembled compositionally:
   - affine layer contributes its row-sum bound,
   - ReLU contributes factor `1`,
   - skip operator contributes factor `≤ 1`,
   - concatenation contributes `max`,
   - additive merge contributes sum of weighted predecessor constants,
   - average pooling contributes coefficient-weighted average, hence no blow-up under convex averaging.  
   This is the exact extension needed to certify robustness of architectures with average pooling and parallel branch aggregation.

### Why this matters

This theorem is the missing bridge between tropical robustness certificates for purely max-plus / residual architectures and realistic piecewise-linear DAGs used in practice. Average pooling and additive branch aggregation are ubiquitous in convolutional and graph/message-passing networks, but they are not tropical-max primitives. Showing that they still preserve the support-envelope / oscillation structure via coefficient-weighted bounds means the existing tropical margin certificate machinery extends to a substantially broader class of models.

Mathematically, the novelty is that tropical-style certification survives non-idempotent convex and additive merges because the relevant invariant is not strict max-plus linearity, but a compositional oscillation envelope. Formally, this gives a clean recursive semantics for a certified radius:
```lean
r_cert = marginToClass f x c / (2 * K_net),
```
with `K_net` explicitly computable from local operator bounds. This is the right theorem to support future work on tropical certified robustness for CNN pooling layers, DAG architectures, and message-passing networks.

### Strong optional extension: exactness on a fixed linear region

If the network is represented recursively and you can define an “activation pattern fixed on a neighborhood” hypothesis, prove a local exactness theorem:

```lean
theorem local_linear_exact_certificate
    {d C : ℕ}
    {f : (Fin d → ℝ) → Fin C → ℝ}
    {x : Fin d → ℝ}
    {J : Matrix (Fin C) (Fin d) ℝ}
    {r K : ℝ}
    (hlin : ∀ y, BddPerturbation x y r → f y = fun i => ∑ j, J i j * y j + (f x i - ∑ j, J i j * x j))
    (hK : ∀ i, ∑ j, |J i j| ≤ K) :
    HasOscillationBound f K := by
```

Then combine this with the margin theorem to show that inside a fixed activation region the certificate is exact up to the induced `∞ → ∞` norm of the local Jacobian. Even a one-sided formal statement here would be valuable, because it clarifies that the compositional `K_net` is not merely safe but locally sharp on linear pieces.

### Suggested implementation order

1. `BddPerturbation`, `HasOscillationBound`.
2. `smul_add`, `add`, finite weighted sum, average pooling.
3. affine and ReLU primitives.
4. margin-to-robustness theorem.
5. optional recursive network syntax and global certificate theorem.

Try to keep the final theorem in a form that can be instantiated both for a hand-built expression and later for an explicit DAG datatype.

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

Research domain: MachineLearning
Research mode: prove
