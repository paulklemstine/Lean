def md_chain(compress, iv, message):
    state = iv
    for block in message:
        state = compress(state, block)
    return state