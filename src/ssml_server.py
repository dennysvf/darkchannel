"""
SSML Service - Servidor FastAPI para processamento SSML
Foco em português do Brasil (pt-BR)
"""
from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional, List, Dict, Any
import logging
import sys
from pathlib import Path

# Adicionar src ao path
sys.path.insert(0, str(Path(__file__).parent))

from ssml.parser import SSMLParser
from ssml.validator import SSMLValidator

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Criar app FastAPI
app = FastAPI(
    title="DarkChannel SSML Service",
    description="Serviço de processamento SSML para pt-BR",
    version="1.0.0"
)


# Models
class SSMLRequest(BaseModel):
    text: str
    validate_only: Optional[bool] = False


class SSMLResponse(BaseModel):
    success: bool
    chunks: Optional[List[Dict[str, Any]]] = None
    plain_text: Optional[str] = None
    total_breaks: Optional[int] = None
    total_duration: Optional[float] = None
    errors: Optional[List[str]] = None


class ValidationResponse(BaseModel):
    valid: bool
    errors: List[str]


# Endpoints
@app.get("/")
async def root():
    """Endpoint raiz"""
    return {
        "service": "DarkChannel SSML Service",
        "version": "1.0.0",
        "language": "pt-BR",
        "status": "online"
    }


@app.get("/health")
async def health():
    """Health check"""
    return {"status": "healthy"}


@app.post("/api/v1/ssml/parse", response_model=SSMLResponse)
async def parse_ssml(request: SSMLRequest):
    """
    Parseia SSML e retorna chunks processáveis

    Args:
        request: Texto com tags SSML

    Returns:
        Chunks processados com metadados
    """
    try:
        logger.info(f"Parseando SSML: {request.text[:100]}...")

        # Validar primeiro se solicitado
        if request.validate_only:
            validator = SSMLValidator()
            is_valid, errors = validator.validate(request.text)

            if not is_valid:
                return SSMLResponse(
                    success=False,
                    errors=errors
                )

        # Parsear
        parser = SSMLParser()
        chunks = parser.parse(request.text)

        # Estatísticas
        breaks = [c for c in chunks if c["type"] == "break"]
        total_duration = sum(b["duration"] for b in breaks)

        return SSMLResponse(
            success=True,
            chunks=chunks,
            plain_text=parser.get_plain_text(),
            total_breaks=len(breaks),
            total_duration=total_duration
        )

    except Exception as e:
        logger.error(f"Erro ao parsear SSML: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/ssml/validate", response_model=ValidationResponse)
async def validate_ssml(request: SSMLRequest):
    """
    Valida SSML sem processar

    Args:
        request: Texto com tags SSML

    Returns:
        Resultado da validação
    """
    try:
        validator = SSMLValidator()
        is_valid, errors = validator.validate(request.text)

        return ValidationResponse(
            valid=is_valid,
            errors=errors
        )

    except Exception as e:
        logger.error(f"Erro ao validar SSML: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/api/v1/info")
async def get_info():
    """Informações sobre o serviço"""
    return {
        "service": "SSML Parser Service",
        "version": "1.0.0",
        "language": "pt-BR",
        "supported_tags": [
            "speak", "break", "prosody", "phoneme",
            "emphasis", "p", "s"
        ],
        "features": {
            "break": "Pausas controladas",
            "prosody_rate": "Controle de velocidade (OpenVoice V2)",
            "prosody_pitch": "Controle de tom (OpenVoice V2)",
            "phoneme": "Pronúncia fonética (IPA)",
            "emphasis": "Ênfase em palavras"
        }
    }


# Executar servidor
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8888,
        log_level="info"
    )
