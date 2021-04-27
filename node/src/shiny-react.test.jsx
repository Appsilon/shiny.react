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

  test('converts a list', () => {
    const aDiv = { name: 'div', attribs: {}, children: [] };
    const aJson = [aDiv, aDiv];

    const elements = hydrateJsxAndHtmlTags(aJson);

    expect(isValidElement(elements[0])).toBe(true);
    expect(elements[0].type).toBe('div');
    expect(isValidElement(elements[1])).toBe(true);
    expect(elements[1].type).toBe('div');
  });

  test('passes numeric args verbatim', () => {
    const aValue = 400;
    const aJson = { name: 'div', attribs: { width: aValue }, children: [] };

    const element = hydrateJsxAndHtmlTags(aJson);

    expect(isValidElement(element)).toBe(true);
    expect(element.props.width).toBe(aValue);
  });
});
