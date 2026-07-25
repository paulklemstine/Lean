# Hydrogen’s Hidden Staircase: Energy, Rotation, and a Two-Colored Map of Light

Hydrogen is the simplest atom, but “simple” does not mean featureless. A single electron bound to a single proton already contains three striking mathematical worlds. Its negative energies form an infinite staircase that climbs toward ionization without ever reaching it. Its angular wave patterns wind around an axis by an integer number of turns. And its idealized electric-dipole transitions form a graph that can be colored with just two colors, making every odd cycle impossible.

These three worlds—spectral geometry, complex oscillation, and graph theory—fit together in a compact model. The point is not to reconstruct the full analytic machinery of the Coulomb Schrödinger operator. Instead, we isolate a set of exact structural statements that explain why hydrogen’s spectrum has a threshold, why angular momentum is quantized around an axis, and why chains of allowed transitions obey a parity law.

## The staircase below zero

Work in Rydberg energy units, so that the ionization threshold is $0$ and the ground-state energy is $-1$. The positive integers $n=1,2,3,\ldots$ are the principal quantum numbers. Define the bound-state energy at level $n$ by

$$
E_n=-\frac{1}{n^2}.
$$

The idealized spectral set considered here is

$$
\Sigma=\left\{-\frac{1}{n^2}:n\in\mathbb{Z}_{>0}\right\}\cup[0,\infty).
$$

Its two pieces have different physical interpretations. The isolated negative numbers represent bound levels. The nonnegative half-line represents the scattering continuum: energies at or above ionization. In this model these pieces are disjoint, since $E_n<0$ for every positive integer $n$.

The first four steps are familiar:

$$
E_1=-1,\qquad E_2=-\frac14,\qquad E_3=-\frac19,\qquad E_4=-\frac1{16}.
$$

The pattern is not merely decreasing in magnitude. It is strictly increasing as a sequence of real numbers:

$$
E_1<E_2<E_3<\cdots<0.
$$

Indeed, if $a<b$ are positive integers, then $a^2<b^2$, so $1/a^2>1/b^2$, and negating reverses the inequality. Thus $-1/a^2<-1/b^2$.

The staircase has no final negative step. As $n$ grows, $n^2$ grows without bound, so

$$
\lim_{n\to\infty}E_n=0.
$$

This makes $0$ an accumulation point of the bound levels: every open interval around $0$, however narrow, contains some $E_n$. Yet $0$ is not itself one of those negative levels. It belongs instead to the continuum. This is the mathematical shape of a threshold: infinitely many discrete energies crowd beneath a boundary that opens into a continuous range.

That distinction matters whenever spectra are observed rather than merely listed. Far below threshold, neighboring lines are well separated. Near threshold, the energy gap between successive levels shrinks. A spectrometer sees lines bunch together, reflecting the asymptotic crowding encoded by $-1/n^2$.

## Integer winding and angular momentum

Energy is only one label for an atomic state. To describe angular behavior around a chosen axis, introduce an azimuthal angle $\phi$. For any integer $m$, define the complex mode

$$
\psi_m(\phi)=e^{im\phi}.
$$

The integer $m$ is the magnetic quantum number. Why must it be an integer in this elementary picture? A full turn changes $\phi$ to $\phi+2\pi$, and a physical angular mode must return to the same value. For integer $m$,

$$
\psi_m(\phi+2\pi)
=e^{im(\phi+2\pi)}
=e^{im\phi}e^{2\pi im}
=e^{im\phi}
=\psi_m(\phi).
$$

Thus the mode is single-valued after one revolution. Positive and negative values of $m$ wind in opposite directions, while $m=0$ gives a constant azimuthal factor.

Now introduce the dimensionless $z$-component of angular momentum,

$$
L_z=-i\frac{d}{d\phi}.
$$

Differentiation gives

$$
\frac{d}{d\phi}\psi_m(\phi)=im\psi_m(\phi).
$$

Multiplying by $-i$ yields the eigenvalue equation

$$
L_z\psi_m=m\psi_m.
$$

So the integer winding number is simultaneously an angular-momentum eigenvalue. This is a vivid instance of a general quantum idea: symmetry under rotation becomes a differential operator, and periodic wave patterns turn its possible measured values into discrete integers.

These azimuthal modes are the $\phi$-dependent factors that occur in spherical harmonics. The complete spherical harmonics also depend on the polar angle and involve associated Legendre functions. The result here deliberately isolates the rotational factor and its $L_z$ equation; it does not claim the full eigenvalue equation for total angular momentum.

## States as vertices and transitions as edges

The next step replaces a list of quantum states by a network. An orbital state is a pair $(\ell,m)$ satisfying

$$
\ell\in\mathbb{Z}_{\ge 0},\qquad m\in\mathbb{Z},\qquad |m|\le \ell.
$$

Here $\ell$ is the orbital angular-momentum quantum number. In the idealized electric-dipole transition graph, two states $(\ell_a,m_a)$ and $(\ell_b,m_b)$ are joined when

$$
\ell_b=\ell_a+1\quad\text{or}\quad \ell_a=\ell_b+1,
$$

and

$$
|m_a-m_b|\le 1.
$$

Equivalently, the rule is $\Delta\ell=\pm1$ and $\Delta m\in\{-1,0,1\}$. In this model these conditions define the edges; they are not derived from dipole matrix elements. Because absolute differences do not care which endpoint is named first, allowedness is symmetric. The network is therefore undirected.

Now color each vertex according to the parity of $\ell$: color it even when $\ell$ is even and odd when $\ell$ is odd. Every allowed edge changes $\ell$ by exactly one. Consequently, every edge crosses from one color to the other.

This is the central graph-theoretic result: **the idealized dipole transition graph is bipartite, with orbital parity as its two-coloring.** A selection rule has become a global statement about network architecture.

## The parity memory of a walk

The two-coloring does more than classify individual edges. It controls every chain of transitions.

Consider a walk of $k$ allowed edges from state $a=(\ell_a,m_a)$ to state $b=(\ell_b,m_b)$. Each edge flips the parity of $\ell$. After two edges the original parity returns; after three it flips again. In general,

$$
(\ell_a+\ell_b)\bmod 2=k\bmod 2.
$$

This is the **walk-parity theorem**. It says that the endpoints have opposite orbital parity exactly when the number of transitions is odd, and the same parity exactly when it is even.

The proof is a one-line induction in concept. A walk of length $0$ begins and ends at the same vertex, so both sides are even. Appending one allowed edge changes $\ell$ by one and also changes the walk length by one; both parities flip together.

Several consequences arrive immediately. Two successive allowed transitions preserve orbital parity between the initial and final states. More dramatically, an odd-length closed walk cannot exist. If a walk returns to its starting state, then $\ell_a=\ell_b$, making $\ell_a+\ell_b=2\ell_a$ even. The walk-parity theorem forces $k$ to be even. Hence the graph has no odd cycle.

This is more than a visual curiosity. Suppose one wants to search computationally for possible transition sequences. The endpoint parity gives an instant test: any proposed path length with the wrong parity can be rejected before inspecting intermediate states. In spectroscopy, multi-step processes likewise carry parity information. The graph packages that bookkeeping into a structural invariant.

## From single photons to routes through a network

A spectral line records an energy difference. If an electron changes between two bound levels with principal quantum numbers $n_i$ and $n_f$, the magnitude of the idealized photon energy is

$$
|E_{n_f}-E_{n_i}|=\left|\frac{1}{n_i^2}-\frac{1}{n_f^2}\right|.
$$

The energy formula and the transition graph answer different questions. The first supplies possible level differences; the second constrains which angular labels may be connected by one idealized dipole step. Neither alone gives a complete spectrum of line intensities. Still, their combination shows how a laboratory observation can carry several layers of structure: a photon frequency reflects an energy gap, while polarization and angular behavior reflect changes in magnetic and orbital labels.

Longer routes matter too. An excited system may pass through intermediate states, emitting or absorbing more than one photon. The walk-parity law then serves as an accounting principle that survives all intermediate choices. If the initial and final orbital quantum numbers have the same parity, every allowed chain between them has even length. If their parities differ, every chain has odd length. The precise intermediate magnetic labels can vary, but the parity of the number of steps cannot.

This illustrates why graph language is valuable in physics. A graph deliberately forgets much—wavefunction amplitudes, radial integrals, lifetimes, and line strengths—but preserves connectivity. Once connectivity is isolated, global facts become visible. The impossibility of an odd cycle is difficult to see by listing transitions one at a time, yet immediate from the two-color picture.

## Three views of one atom

The model now presents three forms of discreteness.

First, the principal quantum number $n$ produces discrete negative energies $-1/n^2$, even though those levels converge to a continuous threshold. Second, the demand that an angular mode close after $2\pi$ produces integer winding numbers $m$ and the eigenvalue equation $L_z\psi_m=m\psi_m$. Third, the unit change in $\ell$ across an allowed dipole transition produces a two-color graph and a parity law for every path.

The common theme is that local rules generate global organization. The formula $E_n=-1/n^2$ dictates an entire spectral landscape. The local differential action of $L_z$ identifies the integer label of a periodic mode. The local rule $\Delta\ell=\pm1$ forbids every odd cycle, no matter how large the network becomes.

## What remains beyond the model

A clear boundary is essential. The set $\Sigma$ is an idealized spectral set; establishing that it is exactly the operator spectrum of the Coulomb Hamiltonian

$$
H=-\Delta-\frac{2}{r}
$$

requires the theory of unbounded self-adjoint operators on $L^2(\mathbb{R}^3)$, including careful treatment of domains and the singularity at $r=0$. Likewise, a full treatment of spherical harmonics must construct the polar factors and prove the total-angular-momentum equation. Finally, a first-principles derivation of dipole selection rules must show that forbidden transition matrix elements vanish, rather than taking the edge conditions as a definition.

Those deeper questions do not diminish the present conclusions. They locate them precisely. Within the model, the bound levels are negative, strictly ordered, and accumulated at zero; the continuum begins at zero and is disjoint from them; integer azimuthal modes are periodic eigenfunctions of $L_z$; and the dipole transition graph is bipartite, with walk length recorded in endpoint parity.

Hydrogen’s apparent simplicity conceals a remarkable unity. A staircase of fractions, a rotating complex phase, and a two-colored graph are not three unrelated metaphors. They are three exact mathematical lenses on quantization—and together they show how the rules of an atom become the geometry of a spectrum and the combinatorics of light.