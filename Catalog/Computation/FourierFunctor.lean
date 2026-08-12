import Computation.FourierFunctor.Category
import Computation.FourierFunctor.Duality
import Computation.FourierFunctor.Transform
import Computation.FourierFunctor.Uncertainty
import Computation.FourierFunctor.Convolution
import Computation.FourierFunctor.Exactness
import Computation.FourierFunctor.Poisson
import Computation.FourierFunctor.Sharpness
import Computation.FourierFunctor.Rigidity
import Computation.FourierFunctor.GaussSum
import Computation.FourierFunctor.AbstractUncertainty
import Computation.FourierFunctor.SelfDuality

/-!
# Fourier analysis as a functor

Aggregator for the `FourierFunctor` development:

* `Category`     — the category `FinAb` and the Pontryagin dual functor;
* `Duality`      — Pontryagin duality as an equivalence `FinAb ≌ FinAbᵒᵖ`;
* `Transform`    — the Fourier transform as a natural isomorphism of functors;
* `Uncertainty`  — the Donoho–Stark uncertainty principle;
* `Convolution`  — convolution theorem, Plancherel, `𝓕² = |G|·antipode`;
* `Exactness`    — exactness of duality and the character extension theorem;
* `Poisson`      — Poisson summation from annihilator duality;
* `Sharpness`    — the subgroup equality case of the uncertainty principle;
* `Rigidity`     — the converse: the extremal functions are *exactly* the
  modulated coset indicators (`donoho_stark_equality_iff`);
* `GaussSum`     — the opposite extreme: quadratic Gauss sums, flatness of the
  quadratic phase on `ZMod N` for odd `N`;
* `AbstractUncertainty` — the uncertainty principle for an arbitrary bounded
  kernel with a bounded inversion kernel, recovering Donoho–Stark, the
  Elad–Bruckstein coherence bound and the Hadamard/mutually-unbiased case;
* `SelfDuality`  — Pontryagin duality as a self-adjunction, its hom-set
  bijection identified with the bicharacter swap, and the Fourier kernel as the
  image of the identity.
-/