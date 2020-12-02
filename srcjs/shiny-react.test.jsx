import { isValidElement } from 'react';
import { inputClassName, hydrateJsxAndHtmlTags } from './shiny-react.jsx';

describe('inputClassName()', () => {
  test('returns a valid CSS class name', () => {
    const aPackageName = 'shiny.fabric';
    const aCompontentName = 'ActionButton';

    const name = inputClassName(aPackageName, aCompontentName);

    expect(name).toBe('shiny-fabric-ActionButton');
  });
});

describe('hydrateJsxAndHtmlTags()', () => {
  test('correctly converts an empty div', () => {
    const aJson = { name: 'div', attribs: {}, children: [] };

    const element = hydrateJsxAndHtmlTags(aJson);

    expect(isValidElement(element)).toBe(true);
    expect(element.type).toBe('div');
  });
});
