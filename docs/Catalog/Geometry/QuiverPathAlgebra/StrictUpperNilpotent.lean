import Mathlib

/-!
# Strictly upper triangular matrices are nilpotent of index `n`

The path algebra of a finite acyclic quiver with longest path length `n - 1`
embeds, via a topological order on the `n` vertices, into the algebra of
`n × n` upper triangular matrices, with the *arrow ideal* `𝔽Q≥1` landing inside
the **strictly** upper triangular matrices.  This file proves the algebraic
heart of nilpotency: a product of `n` strictly upper triangular `n × n`
matrices is the zero matrix.

The proof tracks a *shift* invariant: a matrix `M` "has shift `k`" if `M i j = 0`
whenever `j < i + k`.  Strictly upper triangular means shift `1`.  Multiplying a
shift-`k` matrix by a shift-`l` matrix yields shift `k + l`, and shift `n` over
`Fin n` forces the matrix to vanish (since `j < n ≤ i + n` always).

## Main results

* `Matrix.Shift.mul` — shift is additive under matrix multiplication.
* `Matrix.Shift.eq_zero_of_top` — a shift-`n` matrix over `Fin n` is zero.
* `Matrix.listProd_shift` — the product of a list of shift-`1` matrices has shift
  equal to the list length.
* `Matrix.prod_ofFn_strictUpper_eq_zero` — the product of `n` strictly upper
  triangular `n × n` matrices is `0`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): "Bounded path length ⇒ the arrow ideal is nilpotent
of index = number of vertices."  Experiment (Experimenter): the naive
`induction on n` on raw matrix entries stalls; the winning idea was the
quantitative `Shift k` filtration, which makes nilpotency a clean additive law
`Shift k * Shift l = Shift (k+l)` plus the boundary fact `Shift n = 0`.
Analysis (Analyst): this is exactly the associated-graded picture `J^k/J^{k+1}`
of the path algebra, with `k` = path length.  Critique (Critic): we must use
`List.prod` rather than `Finset.prod`, since the matrix monoid is
noncommutative; the order of the product is irrelevant to the conclusion `= 0`.
-/

namespace Matrix

variable {n : ℕ} {R : Type*} [Semiring R]

/-- `Shift k M` means every entry strictly below the `k`-th superdiagonal vanishes:
`M i j = 0` whenever `j < i + k`. -/
def Shift (k : ℕ) (M : Matrix (Fin n) (Fin n) R) : Prop :=
  ∀ i j : Fin n, (j : ℕ) < (i : ℕ) + k → M i j = 0

/-- A strictly upper triangular matrix has shift `1`. -/
def StrictUpper (M : Matrix (Fin n) (Fin n) R) : Prop := Shift 1 M

/--
The identity matrix has shift `0` (it has no entries strictly below the
diagonal).
-/
theorem Shift.one : Shift 0 (1 : Matrix (Fin n) (Fin n) R) := by
  intro i j; by_cases hij : i = j <;> simp_all +decide

/--
Shift is additive under multiplication.
-/
theorem Shift.mul {k l : ℕ} {M N : Matrix (Fin n) (Fin n) R}
    (hM : Shift k M) (hN : Shift l N) : Shift (k + l) (M * N) := by
  intro i j hij; rw [ Matrix.mul_apply ] ; simp_all +decide [ Shift ]
  exact Finset.sum_eq_zero fun x hx => by by_cases hx' : ( x : ℕ ) < ( i : ℕ ) + k <;> [ rw [ hM _ _ hx', MulZeroClass.zero_mul ] ; rw [ hN _ _ ( by omega ), MulZeroClass.mul_zero ] ] ;

/--
A matrix over `Fin n` with shift `n` is the zero matrix.
-/
theorem Shift.eq_zero_of_top {M : Matrix (Fin n) (Fin n) R} (hM : Shift n M) :
    M = 0 := by
  exact Matrix.ext fun i j => by simpa using hM i j ( by linarith [ Fin.is_lt i, Fin.is_lt j ] ) ;

/--
The product of a list of shift-`1` matrices has shift equal to the length of
the list.
-/
theorem listProd_shift (l : List (Matrix (Fin n) (Fin n) R))
    (hl : ∀ M ∈ l, StrictUpper M) : Shift l.length l.prod := by
  induction' l with M l ih;
  · exact Matrix.Shift.one;
  · convert Shift.mul ( hl M ( by simp +decide ) ) ( ih fun M' hM' => hl M' ( by simp +decide [ hM' ] ) ) using 1;
    simp +decide [ add_comm ]

/--
**Nilpotency of the arrow ideal.** The product of `n` strictly upper
triangular `n × n` matrices is the zero matrix.
-/
theorem prod_ofFn_strictUpper_eq_zero (a : Fin n → Matrix (Fin n) (Fin n) R)
    (h : ∀ i, StrictUpper (a i)) : (List.ofFn a).prod = 0 := by
  convert listProd_shift _ _;
  any_goals exact List.ofFn a;
  any_goals try exact inferInstance;
  · rw [ List.length_ofFn ];
    exact ⟨ fun h => h.symm ▸ fun _ _ _ => rfl, fun h => Shift.eq_zero_of_top h ⟩;
  · grind

end Matrix

/-!
## The symmetrized monomial and standard polynomial are identities of `𝔽Q≥1`

We now harvest the *provable half* of the v19d mission statement: for a finite
acyclic quiver `Q` with longest path length `n - 1`, the degree-`n` symmetrized
monomial `S(x₁,…,xₙ) = ∑_{σ ∈ Sₙ} x_{σ(1)} ⋯ x_{σ(n)}` and the degree-`n`
**standard polynomial** `Sₙ(x₁,…,xₙ) = ∑_{σ} sgn(σ) · x_{σ(1)} ⋯ x_{σ(n)}` both
vanish identically on the principal subalgebra `𝔽Q≥1`, modelled by the strictly
upper triangular `n × n` matrices.

### Relation to the Amitsur–Levitzki theorem
Amitsur–Levitzki (MR36751) states the standard polynomial `S_{2n}` is the
minimal-degree standard identity of the *full* matrix algebra `Mₙ(𝔽)`.  Here is
its nilpotent shadow: on the strictly upper triangular subalgebra the standard
identity already appears in degree `n`, and indeed the *unsigned* symmetrized
monomial vanishes too — which is false for `Mₙ`.  The sign is irrelevant because
every individual monomial is already `0`.
-/

namespace PI

open scoped BigOperators

variable {A : Type*} [Ring A] {n : ℕ}

/-- The degree-`n` symmetrized monomial `∑_{σ} a_{σ(1)} ⋯ a_{σ(n)}`. -/
def symMono (a : Fin n → A) : A :=
  ∑ σ : Equiv.Perm (Fin n), (List.ofFn (fun i => a (σ i))).prod

/-- The degree-`n` standard polynomial `∑_{σ} sgn(σ) · a_{σ(1)} ⋯ a_{σ(n)}`. -/
def stdPoly (a : Fin n → A) : A :=
  ∑ σ : Equiv.Perm (Fin n),
    (Equiv.Perm.sign σ : ℤ) • (List.ofFn (fun i => a (σ i))).prod

/--
**Abstract principle.** If every `n`-fold product in `A` vanishes (i.e. the
relevant subalgebra is nilpotent of index `≤ n`), then the symmetrized monomial
vanishes.
-/
theorem symMono_eq_zero (a : Fin n → A)
    (h : ∀ b : Fin n → A, (List.ofFn b).prod = 0) : symMono a = 0 := by
  exact Finset.sum_eq_zero fun σ _ => h _

/--
**Abstract principle.** If every `n`-fold product in `A` vanishes, then the
standard polynomial vanishes.
-/
theorem stdPoly_eq_zero (a : Fin n → A)
    (h : ∀ b : Fin n → A, (List.ofFn b).prod = 0) : stdPoly a = 0 := by
  exact Finset.sum_eq_zero fun σ _ => by simp +decide [ h ( fun i => a ( σ i ) ) ] ;

variable {R : Type*} [Ring R]

/--
**The symmetrized monomial is a polynomial identity of `𝔽Q≥1`.** On the
strictly upper triangular `n × n` matrices the degree-`n` symmetrized monomial
vanishes for every choice of arguments.
-/
theorem symMono_strictUpper_eq_zero (a : Fin n → Matrix (Fin n) (Fin n) R)
    (h : ∀ i, Matrix.StrictUpper (a i)) : symMono a = 0 := by
  refine' Finset.sum_eq_zero _;
  intro σ _; exact Matrix.prod_ofFn_strictUpper_eq_zero (fun i => a (σ i)) (fun i => h (σ i));

/--
**The standard polynomial is a polynomial identity of `𝔽Q≥1`.** On the
strictly upper triangular `n × n` matrices the degree-`n` standard polynomial
vanishes for every choice of arguments.
-/
theorem stdPoly_strictUpper_eq_zero (a : Fin n → Matrix (Fin n) (Fin n) R)
    (h : ∀ i, Matrix.StrictUpper (a i)) : stdPoly a = 0 := by
  refine' Finset.sum_eq_zero _;
  intro σ _; rw [ Matrix.prod_ofFn_strictUpper_eq_zero _ fun i => h _ ] ; simp +decide ;

end PI