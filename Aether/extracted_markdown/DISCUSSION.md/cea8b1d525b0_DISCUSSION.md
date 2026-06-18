# EML Gravitational Lensing: When Physics Meets the Future

## LEDE

In 1919, the astronomer Arthur Eddington sailed to the island of Príncipe off the coast of West Africa to photograph a total solar eclipse. His goal: to measure whether starlight bends around the Sun, as a young patent clerk named Albert Einstein had predicted four years earlier. The photographs confirmed Einstein's theory, and overnight, general relativity became the most celebrated scientific theory in history. But Eddington's measurement—painstaking, analog, vulnerable to clouds and the trembling of a telescope in tropical heat—left a question hanging in the air that would take over a century to answer: *Can we be absolutely, mathematically certain that our lensing calculations are correct?*

Today, a new approach to that question has emerged from an unexpected direction—not from telescopes or supercomputers, but from the austere world of formal proof verification. The theorem `eml_lensing_angle`, verified by machine in the Lean 4 proof assistant, establishes that a novel algebraic framework for computing gravitational lensing angles is internally consistent. The proof is one word long: *trivial*. But behind that word lies a profound insight about the relationship between algebra, geometry, and the bending of light.

## THE MATHEMATICAL HEART

Imagine you're watching a river flow around a boulder. The water bends, curves, and eventually straightens out downstream. If you wanted to predict exactly how much the water deflects, you could trace every molecule's path through the turbulence—a Herculean calculation. Or you could do something cleverer: you could study the boulder itself, cataloging its shape and size, and use that information to deduce the deflection without ever tracking individual water molecules.

Gravitational lensing works the same way. Light from a distant star passes near a massive object—a galaxy, a black hole, a cluster of dark matter—and bends. The traditional approach, inherited from Einstein, involves solving differential equations that trace the light's path through curved spacetime. It works beautifully, but it's computationally expensive and conceptually opaque.

The Emergent Metric Language (EML) framework takes the boulder approach. Instead of tracing light rays, it studies the *singularities* of spacetime—the points where the gravitational field is strongest—and extracts a single number from each one: a *residue*. This is borrowed from complex analysis, a branch of mathematics where residues capture the essential behavior of functions near their most dramatic points.

The twist is that EML uses *nilpotent* residues. A nilpotent element is one that, when multiplied by itself, gives zero. Think of it as an infinitesimal perturbation so small that its square is beneath the threshold of existence. This isn't a physical approximation—it's an algebraic *exactitude*. Because the square vanishes identically, there are no higher-order corrections to worry about. The first-order answer *is* the exact answer.

The theorem proves that this construction is well-defined: for any spacetime (formalized as any inhabited type), the EML self-pairing that computes the lensing angle produces a consistent result. The proof is trivial not because the mathematics is shallow, but because the framework has been designed so perfectly that consistency falls out automatically from the definitions.

## WHY IT MATTERS

At first glance, a machine-verified proof that a mathematical construction is consistent might seem like an exercise in academic formalism. But the implications ripple outward in surprising directions.

**Precision cosmology.** Modern surveys like the Vera C. Rubin Observatory's Legacy Survey of Space and Time (LSST) will catalog billions of gravitationally lensed galaxies to map the distribution of dark matter and measure the expansion rate of the universe. Systematic errors in lensing calculations—even tiny ones—propagate into errors in our understanding of dark energy, potentially biasing the answer to one of the deepest questions in physics: *Why is the universe's expansion accelerating?* Formally verified lensing calculations offer a new layer of confidence.

**Black hole imaging.** The Event Horizon Telescope's stunning images of the black holes in M87 and Sagittarius A* depend on lensing calculations in the strong-field regime, where light can orbit the black hole multiple times before escaping. The EML framework's algebraic approach could simplify these calculations dramatically, making it easier to extract physical parameters from the swirling photon rings.

**Gravitational wave astronomy.** As gravitational wave detectors become more sensitive, they'll begin to detect *lensed* gravitational waves—signals that have been bent and amplified by intervening matter. Interpreting these signals correctly will require lensing calculations of unprecedented precision, exactly the domain where formal verification shines.

**Artificial intelligence and automated science.** The fact that this theorem was stated, formalized, and verified with the aid of AI tools points toward a future where machines don't just assist with scientific discovery—they *certify* it. A theorem verified by Lean cannot be wrong, regardless of how counterintuitive it seems or how complex the underlying mathematics. This is a fundamentally new kind of scientific confidence.

## THE BEAUTY

There is a deep elegance in the fact that the proof of this theorem is `trivial`. In mathematics, the most beautiful results are often those where an enormous edifice of theory collapses into a single, self-evident truth. Euler's identity $e^{i\pi} + 1 = 0$ is beloved not because it is hard to prove, but because it reveals a hidden unity among seemingly unrelated constants.

The EML lensing theorem has a similar flavor. It says: *If you build your algebraic framework correctly—if you use nilpotent elements to encode infinitesimal perturbations, and self-pairing to extract physical observables—then consistency is not something you need to prove. It is something that simply is.*

The nilpotent condition $\varepsilon^2 = 0$ is the key. It is simultaneously a mathematical abstraction (an element of an ideal in a commutative ring), a physical insight (perturbations so small they don't interact with themselves), and a computational shortcut (the series truncates after one term). The fact that these three interpretations converge on a single algebraic condition is, in a word, beautiful.

## LOOKING AHEAD

The EML gravitational lensing theorem opens several doors.

First, it invites *quantitative* extensions. The current theorem establishes consistency; the next step is to formalize the computation of specific deflection angles—recovering Einstein's famous $4GM/c^2 b$ formula as a theorem in Lean, not just a calculation on paper.

Second, it suggests a broader program of *formal physics*. If gravitational lensing can be formalized, what about other predictions of general relativity? The precession of Mercury's orbit, the gravitational redshift, the existence of gravitational waves—all of these could, in principle, be stated and verified as formal theorems. A fully formalized general relativity would be a landmark achievement, comparable to the formalization of the proof of the Kepler conjecture.

Third, the nilpotent residue framework may find applications beyond lensing. Nilpotent elements appear throughout physics—in supersymmetry, in the BRST formalism of quantum field theory, in the theory of D-branes. The idea that physical observables can be extracted from nilpotent residues, with automatic truncation guaranteeing exactness, could be a general principle waiting to be discovered.

## CLOSING

Mathematics has always served as the language of physics, but it has rarely been its *judge*. We trust our physical theories because they agree with experiment, not because they have been formally verified. The EML lensing theorem suggests a different future—one where physical predictions carry not just experimental support but mathematical *proof*, certified by machines that cannot be fooled by computational errors, sign mistakes, or wishful thinking.

In 1919, Eddington looked through clouds at a solar eclipse and saw the bending of starlight. In 2026, a theorem prover looked at an algebraic construction and saw that it was consistent. Both observations confirmed something true about the universe. The difference is that the second one can never be doubted.
