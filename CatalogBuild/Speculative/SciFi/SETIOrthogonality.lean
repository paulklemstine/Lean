/-! # CatalogBuild.Speculative.SciFi.SETIOrthogonality

Auto-generated from theorem catalog database.
Domain: Speculative/SciFi
Declarations: 1
-/

import Mathlib

/-- SETI Prime-Modulated Orthogonality Decomposition.
The SETI array detects weak periodic signals buried in cosmic noise. A linguist-druid from the EML project proposes that advanced civilizations broadcast on carriers whose periods are prime powers, modulating each channel by a distinct Dirichlet character. Because non-principal characters are orthogonal under pointwise multiplication, a receiver that integrates over one complete period can separate an arbitrarily large number of alien conversations with zero cross-talk. The theorem guarantees that even if the Milky Way is a noisy party, every speaker can be isolated by number-theoretic tuning.
Mathematical Concept: Fourier analysis on finite abelian groups (orthogonality relations for Dirichlet characters). Alien carriers encoded with distinct prime-periodic modulations behave as orthogonal basis vectors in the Hilbert space of functions on (ℤ/qℤ)×. Cross-correlation over a complete period vanishes exactly, enabling noiseless channel separation.
Proof Strategy: Use the group-ring structure of ℂ[(ℤ/qℤ)×]. Recognize the sum as the inner product ⟨χ, ψ⟩ in the space of class functions. Apply the Orthogonality Relations for irreducible characters of finite abelian groups: the sum over the group of χ(a)ψ(a)⁻¹ equals |G| if χ = ψ and 0 otherwise. In Lean, unfold the definition of DirichletCharacter, use the fact that distinct characters have distinct kernels, and apply the orthogonality lemma from the representation theory of finite groups (available in mathlib via AddChar/Pontryagin duality).
Difficulty: master
Arc: Cryptographic Gravity -/
theorem seti_orthogonality_decomposition
    {q : ℕ} [NeZero q] [Fintype (ZMod q)ˣ]
    (χ ψ : DirichletCharacter ℂ q) (h : χ ≠ ψ) :
    ∑ a : (ZMod q)ˣ, χ a * ψ (a⁻¹) = 0 := by
  sorry

