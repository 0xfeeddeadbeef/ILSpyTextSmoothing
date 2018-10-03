/*
Copyright 2018 George Chakhidze <0xfeeddeadbeef@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

namespace ILSpyTextSmoothing
{
    using System.ComponentModel.Composition;
    using System.Reflection;
    using System.Windows;
    using System.Windows.Media;
    using ICSharpCode.AvalonEdit;
    using ICSharpCode.ILSpy;
    using ICSharpCode.ILSpy.TextView;

    //
    // This plugin uses a trick to auto-activate itself:
    //
    // To be able to "auto-load", plugin command class MUST
    //
    //  - Have ExportMainMenuCommand attribute applied
    //  - Implement IPartImportsSatisfiedNotification interface
    //
    // Both conditions must be satisfied, or else, plugin won't auto-activate.
    //

    [ExportMainMenuCommand(Menu = "_View", Header = "Enable Font Smoothing")]
    public sealed class ILSpyTextSmoother : SimpleCommand, IPartImportsSatisfiedNotification
    {
        private const BindingFlags DefaultBindingFlags = BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.DeclaredOnly;

        public override void Execute(object parameter)
        {
            var decompilerTextView = App.ExportProvider.GetExportedValue<DecompilerTextView>();
            if (decompilerTextView != null)
            {
                var textEditorField = typeof(DecompilerTextView).GetField("textEditor", DefaultBindingFlags);
                var textEditor = textEditorField?.GetValue(decompilerTextView) as TextEditor;

                FontSmoother.Smooth(textEditor);
            }
        }

        public void OnImportsSatisfied()
        {
            Execute(null);
        }

        private static class FontSmoother
        {
            internal static void Smooth(DependencyObject element)
            {
                if (element != null)
                {
                    TextOptions.SetTextFormattingMode(element, TextFormattingMode.Ideal);
                    TextOptions.SetTextRenderingMode(element, TextRenderingMode.Auto);
                    TextOptions.SetTextHintingMode(element, TextHintingMode.Fixed);
                }
            }
        }
    }
}
