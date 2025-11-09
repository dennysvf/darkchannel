"""
SSML Validator - Validador de SSML
"""
from xml.etree import ElementTree as ET
from typing import Tuple, List
import logging

logger = logging.getLogger(__name__)


class SSMLValidator:
    """Validador de SSML"""

    SUPPORTED_TAGS = {
        "speak", "break", "prosody", "phoneme",
        "emphasis", "p", "s", "lang"
    }

    REQUIRED_ATTRIBUTES = {
        "break": [],  # time é opcional
        "phoneme": ["alphabet", "ph"],
        "prosody": [],  # rate, pitch, volume são opcionais
    }

    def validate(self, ssml_text: str) -> Tuple[bool, List[str]]:
        """
        Valida SSML

        Returns:
            (is_valid, errors)
        """
        errors = []

        try:
            # Preparar SSML
            if not ssml_text.strip().startswith("<speak"):
                ssml_text = f"<speak>{ssml_text}</speak>"

            # Tentar parsear
            root = ET.fromstring(ssml_text)

            # Validar estrutura
            self._validate_element(root, errors)

            return (len(errors) == 0, errors)

        except ET.ParseError as e:
            errors.append(f"Erro de sintaxe XML: {e}")
            return (False, errors)

    def _validate_element(self, element: ET.Element, errors: List[str]):
        """Valida elemento recursivamente"""
        tag = element.tag.lower()

        # Verificar se tag é suportada
        if tag not in self.SUPPORTED_TAGS:
            errors.append(f"Tag não suportada: <{tag}>")

        # Verificar atributos obrigatórios
        if tag in self.REQUIRED_ATTRIBUTES:
            required = self.REQUIRED_ATTRIBUTES[tag]
            for attr in required:
                if attr not in element.attrib:
                    errors.append(
                        f"Atributo obrigatório '{attr}' ausente em <{tag}>"
                    )

        # Validar filhos
        for child in element:
            self._validate_element(child, errors)
