/-! # CatalogBuild.Cryptography.Ethereum.CarmichaelHelper

Auto-generated from theorem catalog database.
Domain: Cryptography/Ethereum
Declarations: 1
-/

import Mathlib

lemma exists_prime_dvd (n : ℕ) (hn : 1 < n) : ∃ p, Nat.Prime p ∧ p ∣ n := by
  exact Nat.exists_prime_and_dvd hn.ne'
