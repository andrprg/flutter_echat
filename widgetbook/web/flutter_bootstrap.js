{{flutter_js}}
{{flutter_build_config}}

// Обход Shader compilation error (unknown error) в Chrome/CanvasKit:
// драйвер GPU / ANGLE не компилирует шейдеры Skia. CPU-рендер медленнее, но стабилен.
// Отключить: ?gpu=1 в URL. Включить принудительно: ?cpu=1.
const params = new URLSearchParams(window.location.search);
const forceGpu = params.has('gpu');
const forceCpu = params.has('cpu') || !forceGpu;

_flutter.loader.load({
  config: {
    canvasKitForceCpuOnly: forceCpu,
  },
});
