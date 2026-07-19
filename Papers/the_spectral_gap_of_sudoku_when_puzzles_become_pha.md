# Why the computational evidence stage was skipped

The proposed computation is not reproducible from the supplied specification.
The state space behind “randomly swaps two compatible entries,” the meaning of
compatible, treatment of rejected moves, and the puzzle sample are all
unspecified. Different choices produce different transition matrices and
spectra. Moreover, exact enumeration of 9×9 completion spaces is not a concise
small-case calculation.

Rather than report arbitrary or unchecked numerical results, this phase proves
a model-independent finite-chain theorem: for any finite symmetric Markov
kernel, a nonempty proper closed class produces two linearly independent fixed
observables and therefore the zero-gap obstruction. Future exact computation
should begin with a fully specified 4×4 analogue and rational transition
matrix, as described in `FUTURE_DIRECTIONS.md`.
