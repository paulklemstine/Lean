# Why a separate computational-evidence stage was skipped

The selected result is a symbolic game-hopping theorem, not a numerical conjecture or an enumerative claim. Its content is the triangle inequality for finite statistical distance and induction over a chain of games, so sampling cannot establish the universal statement.

Instead, `Catalog/Cryptography/LWE/INDCPA.lean` contains kernel-checked small finite examples on `Bool`: opposite point masses have ℓ¹ gap `2`, while identical point masses have gap `0`. These examples check the normalization and boundary cases without treating computation as a substitute for proof.
