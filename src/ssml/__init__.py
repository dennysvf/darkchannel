"""
SSML Parser Module
Suporte a Speech Synthesis Markup Language para pt-BR
"""

__version__ = "1.0.0"
__author__ = "DarkChannel Team"

from .parser import SSMLParser
from .validator import SSMLValidator

__all__ = ["SSMLParser", "SSMLValidator"]
