@echo off
where godot >nul 2>nul
if errorlevel 1 (
  echo Godot 4 was not found in PATH.
  echo Install Godot 4.x, then run this file again.
  pause
  exit /b 1
)
godot --editor project.godot
