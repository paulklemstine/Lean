from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional, Dict
import uvicorn
import torch
from transformers import AutoTokenizer
from petals import AutoDistributedModelForCausalLM

app = FastAPI(title="Petals OpenAI Bridge")

# --- Configuration ---
# Choose a model supported by the Petals network (e.g., Llama-3-70B-Instruct, Mixtral, etc.)
MODEL_NAME = "meta-llama/Meta-Llama-3-70B-Instruct" 

print(f"Loading Tokenizer for {MODEL_NAME}...")
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)

print(f"Connecting to Petals network for {MODEL_NAME}...")
# This connects to the public swarm. It loads the embedding/LM head locally 
# and routes the transformer blocks over the internet.
model = AutoDistributedModelForCausalLM.from_pretrained(MODEL_NAME)

# --- OpenAI API Schemas ---
class Message(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    model: str = MODEL_NAME
    messages: List[Message]
    temperature: Optional[float] = 0.7
    max_tokens: Optional[int] = 1024

class Choice(BaseModel):
    index: int
    message: Message
    finish_reason: str

class ChatResponse(BaseModel):
    id: str = "petals-chat-id"
    object: str = "chat.completion"
    created: int = 0
    model: str
    choices: List[Choice]

# --- API Endpoints ---
@app.post("/v1/chat/completions", response_model=ChatResponse)
async def chat_completions(request: ChatRequest):
    try:
        # Convert standard OpenAI messages dict to the format the HF tokenizer expects
        chat_messages = [{"role": m.role, "content": m.content} for m in request.messages]
        
        # Apply the specific chat template for the loaded model (crucial for Instruct models)
        prompt = tokenizer.apply_chat_template(chat_messages, tokenize=False, add_generation_prompt=True)
        inputs = tokenizer(prompt, return_tensors="pt")["input_ids"]

        # Generate response via the Petals swarm
        # Note: Petals handles the distributed tensor routing under the hood here
        outputs = model.generate(
            inputs, 
            max_new_tokens=request.max_tokens, 
            temperature=request.temperature,
            do_sample=(request.temperature > 0.0)
        )

        # Decode the generated tokens, ignoring the prompt tokens
        generated_tokens = outputs[0, inputs.shape[1]:]
        response_text = tokenizer.decode(generated_tokens, skip_special_tokens=True)

        return ChatResponse(
            model=request.model,
            choices=[
                Choice(
                    index=0,
                    message=Message(role="assistant", content=response_text.strip()),
                    finish_reason="stop"
                )
            ]
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    # Run the bridge locally on port 8000
    print("Petals Bridge active. Point your coding agent to http://localhost:8000/v1")
    uvicorn.run(app, host="0.0.0.0", port=8000)
