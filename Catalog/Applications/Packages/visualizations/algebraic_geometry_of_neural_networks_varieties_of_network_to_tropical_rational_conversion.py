def network_to_tropical(layer, readout_weights, readout_bias):
    pos_slopes, pos_biases = [], []
    neg_slopes, neg_biases = [], []
    for j, (neuron, r) in enumerate(zip(layer, readout_weights)):
        if r >= 0:
            pos_slopes.append(r * neuron.weights)
            pos_biases.append(r * neuron.bias)
        else:
            neg_slopes.append(-r * neuron.weights)
            neg_biases.append(-r * neuron.bias)
    pos_biases[0] += readout_bias
    return MaxOfAffine(pos_slopes, pos_biases), MaxOfAffine(neg_slopes, neg_biases)