import os
import json
import time
import uuid
import asyncio
import sys
from typing import List, Optional, Dict, Any, Union

# ==============================================================================
# DEPENDENCY HELL PATCHES
# These must execute BEFORE we import petals, hivemind, or fastapi.
# ==============================================================================

# --- 1. PYDANTIC V2 COMPATIBILITY PATCH ---
# hivemind needs v1, FastAPI needs v2.
try:
    import pydantic as real_pydantic
    is_v2 = real_pydantic.__version__.startswith("2.")
except ImportError:
    is_v2 = False

if is_v2:
    import pydantic.v1 as pydantic_v1
    sys.modules['pydantic'] = pydantic_v1

# --- 2. HUGGINGFACE HUB COMPATIBILITY PATCH ---
# accelerate crashes on newer huggingface_hub versions.
try:
    import huggingface_hub
    if not hasattr(huggingface_hub, 'split_torch_state_dict_into_shards'):
        huggingface_hub.split_torch_state_dict_into_shards = lambda *args, **kwargs: ({}, None)
except ImportError:
    pass

# --- 3. PYTORCH 2.4+ COMPATIBILITY PATCH ---
# hivemind relies on an internal optimizer state deleted in PyTorch 2.4.
import torch
try:
    import torch.cuda.amp.grad_scaler
    if not hasattr(torch.cuda.amp.grad_scaler, '_refresh_per_optimizer_state'):
        torch.cuda.amp.grad_scaler._refresh_per_optimizer_state = lambda *args, **kwargs: None
except ImportError:
    pass

# ==============================================================================
# IMPORT AI LIBRARIES (They will now see the patched environment)
# ==============================================================================
import transformers

# --- 4. PETALS VERSION ASSERTION BYPASS ---
# Petals enforces transformers < 4.35.0. However, Llama 3.1 and PyTorch 2.4+ 
# require much newer versions. We spoof the version string to bypass the check.
transformers.__version__ = "4.34.1"

from transformers import AutoTokenizer
from petals import AutoDistributedModelForCausalLM

# ==============================================================================
# RESTORE ENVIRONMENT FOR FASTAPI
# ==============================================================================
if is_v2:
    sys.modules['pydantic'] = real_pydantic

from pydantic import BaseModel, Field
from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import StreamingResponse


# ==============================================================================
# API SERVER CONFIGURATION
# ==============================================================================
MODEL_NAME = "meta-llama/Llama-3.1-405B-Instruct" 
PORT = 8000
HOST = "0.0.0.0"

app = FastAPI(title="Petals OpenAI Bridge")

model = None
tokenizer = None

def load_petals():
    global model, tokenizer
    print(f"[*] Loading tokenizer for {MODEL_NAME}...")
    
    HF_TOKEN = os.environ.get("HF_TOKEN")
    
    try:
        tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME, token=HF_TOKEN)
        
        print(f"[*] Connecting to Petals swarm for {MODEL_NAME}...")
        
        # ADD load_in_4bit=True to compress the local 12GB down to ~3GB
        model = AutoDistributedModelForCausalLM.from_pretrained(
            MODEL_NAME, 
            token=HF_TOKEN,
            load_in_4bit=True,
            device_map="auto"
        )
        
    except OSError as e:
        if "gated repo" in str(e).lower() or "401" in str(e):
            print(f"\n[!] ERROR: {MODEL_NAME} is a gated repository.")
            print(f"[!] You must agree to the license and authenticate.")
            print(f"[!] 1. Go to https://huggingface.co/{MODEL_NAME}")
            print(f"[!] 2. Accept the terms to be granted access.")
            print(f"[!] 3. Create a token at https://huggingface.co/settings/tokens")
            print(f"[!] 4. Run the script as: HF_TOKEN='your_token' python3 fastbridge.py\n")
            sys.exit(1)
        raise
    
    print("[+] Connected to Swarm. API ready on http://{}:{}".format(HOST, PORT))


# ==============================================================================
# SCHEMAS & LOGIC
# ==============================================================================
class ChatMessage(BaseModel):
    role: str
    content: str

class ChatCompletionRequest(BaseModel):
    model: str
    messages: List[ChatMessage]
    temperature: Optional[float] = 0.7
    top_p: Optional[float] = 0.9
    max_tokens: Optional[int] = 512
    stream: Optional[bool] = False

def format_prompt(messages: List[ChatMessage]) -> str:
    """Format messages using the model's native chat template."""
    if tokenizer.chat_template:
        # Support both Pydantic v1 (dict) and v2 (model_dump)
        dicts = [m.model_dump() if hasattr(m, 'model_dump') else m.dict() for m in messages]
        return tokenizer.apply_chat_template(dicts, tokenize=False, add_generation_prompt=True)
    
    # Manual fallback
    prompt = ""
    for msg in messages:
        if msg.role == "system":
            prompt += f"<<SYS>>\n{msg.content}\n<</SYS>>\n\n"
        elif msg.role == "user":
            prompt += f"[INST] {msg.content} [/INST]"
        elif msg.role == "assistant":
            prompt += f" {msg.content} "
    return prompt

async def petals_generate_stream(prompt: str, params: Dict[str, Any]):
    """Generator for OpenAI-compatible Server-Sent Events (SSE)."""
    inputs = tokenizer(prompt, return_tensors="pt")["input_ids"]
    
    with model.inference_session(max_length=params['max_tokens'] + inputs.shape[1]) as sess:
        current_ids = inputs
        
        for _ in range(params['max_tokens']):
            outputs = model.generate(
                inputs=current_ids,
                max_new_tokens=1,
                session=sess,
                do_sample=True,
                temperature=params['temperature'],
                top_p=params['top_p']
            )
            
            new_id = outputs[0, -1].item()
            if new_id == tokenizer.eos_token_id:
                break
                
            chunk_text = tokenizer.decode([new_id])
            current_ids = None # Tell Petals to continue the existing session
            
            chunk = {
                "id": f"chatcmpl-{uuid.uuid4()}",
                "object": "chat.completion.chunk",
                "created": int(time.time()),
                "model": MODEL_NAME,
                "choices": [{
                    "index": 0,
                    "delta": {"content": chunk_text},
                    "finish_reason": None
                }]
            }
            yield f"data: {json.dumps(chunk)}\n\n"
            await asyncio.sleep(0.01) # Yield to event loop

    yield "data: [DONE]\n\n"


# ==============================================================================
# ENDPOINTS
# ==============================================================================
@app.post("/v1/chat/completions")
async def chat_completions(request: ChatCompletionRequest):
    if not model:
        raise HTTPException(status_code=503, detail="Model not initialized")

    prompt = format_prompt(request.messages)
    req_dict = request.model_dump() if hasattr(request, 'model_dump') else request.dict()
    
    if request.stream:
        return StreamingResponse(
            petals_generate_stream(prompt, req_dict),
            media_type="text/event-stream"
        )
    
    # Block for full generation
    inputs = tokenizer(prompt, return_tensors="pt")["input_ids"]
    outputs = model.generate(
        inputs, 
        max_new_tokens=request.max_tokens,
        do_sample=True,
        temperature=request.temperature,
        top_p=request.top_p
    )
    
    generated_ids = outputs[0, inputs.shape[1]:]
    response_text = tokenizer.decode(generated_ids, skip_special_tokens=True)
    
    return {
        "id": f"chatcmpl-{uuid.uuid4()}",
        "object": "chat.completion",
        "created": int(time.time()),
        "model": request.model,
        "choices": [{
            "message": {"role": "assistant", "content": response_text},
            "finish_reason": "stop",
            "index": 0
        }],
        "usage": {
            "prompt_tokens": inputs.shape[1],
            "completion_tokens": len(generated_ids),
            "total_tokens": inputs.shape[1] + len(generated_ids)
        }
    }

@app.get("/v1/models")
async def list_models():
    return {
        "object": "list",
        "data": [{
            "id": MODEL_NAME,
            "object": "model",
            "created": int(time.time()),
            "owned_by": "petals"
        }]
    }

if __name__ == "__main__":
    import uvicorn
    load_petals()
    uvicorn.run(app, host=HOST, port=PORT)
