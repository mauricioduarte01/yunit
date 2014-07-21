/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtTest 1.0
import Unity 0.2
import ".."
import "../../../qml/Dash"
import "../../../qml/Components"
import Ubuntu.Components 0.1
import Unity.Test 0.1 as UT

Item {
    id: shell
    width: units.gu(120)
    height: units.gu(100)

    // BEGIN To reduce warnings
    // TODO I think it we should pass down these variables
    // as needed instead of hoping they will be globally around
    property var greeter: null
    property var panel: null
    // BEGIN To reduce warnings

    Scopes {
        id: scopes
    }

    property Item applicationManager: Item {
        signal sideStageFocusedApplicationChanged()
        signal mainStageFocusedApplicationChanged()
    }

    GenericScopeView {
        id: genericScopeView
        anchors.fill: parent

        UT.UnityTestCase {
            id: testCase
            name: "GenericScopeView"
            when: scopes.loaded && windowShown

            property Item previewListView: findChild(genericScopeView, "previewListView")
            property Item header: findChild(genericScopeView, "scopePageHeader")

            function init() {
                genericScopeView.scope = scopes.getScope(1)
                shell.width = units.gu(120)
                genericScopeView.categoryView.positionAtBeginning();
                tryCompare(genericScopeView.categoryView, "contentY", 0)
            }

            function test_isActive() {
                tryCompare(genericScopeView.scope, "isActive", false)
                genericScopeView.isCurrent = true
                tryCompare(genericScopeView.scope, "isActive", true)
                testCase.previewListView.open = true
                tryCompare(genericScopeView.scope, "isActive", false)
                testCase.previewListView.open = false
                tryCompare(genericScopeView.scope, "isActive", true)
                genericScopeView.isCurrent = false
                tryCompare(genericScopeView.scope, "isActive", false)
            }

            function test_showDash() {
                testCase.previewListView.open = true;
                scopes.getScope(1).showDash();
                tryCompare(testCase.previewListView, "open", false);
            }

            function test_hideDash() {
                testCase.previewListView.open = true;
                scopes.getScope(1).hideDash();
                tryCompare(testCase.previewListView, "open", false);
            }

            function test_searchQuery() {
                genericScopeView.scope = scopes.getScope(0);
                genericScopeView.scope.searchQuery = "test";
                genericScopeView.scope = scopes.getScope(1);
                genericScopeView.scope.searchQuery = "test2";
                genericScopeView.scope = scopes.getScope(0);
                tryCompare(genericScopeView.scope, "searchQuery", "test");
                genericScopeView.scope = scopes.getScope(1);
                tryCompare(genericScopeView.scope, "searchQuery", "test2");
            }

            function test_changeScope() {
                genericScopeView.scope.searchQuery = "test"
                genericScopeView.scope = scopes.getScope(2)
                genericScopeView.scope = scopes.getScope(1)
                tryCompare(genericScopeView.scope, "searchQuery", "test")
            }

            function test_filter_expand_collapse() {
                // wait for the item to be there
                waitForRendering(genericScopeView);
                tryCompareFunction(function() { return findChild(genericScopeView, "dashSectionHeader0") != null; }, true);

                var header = findChild(genericScopeView, "dashSectionHeader0")
                var category = findChild(genericScopeView, "dashCategory0")

                waitForRendering(header);
                verify(category.expandable);
                verify(category.filtered);

                var initialHeight = category.height;
                var middleHeight;
                mouseClick(header, header.width / 2, header.height / 2);
                tryCompareFunction(function() { middleHeight = category.height; return category.height > initialHeight; }, true);
                tryCompare(category, "filtered", false);
                tryCompareFunction(function() { return category.height > middleHeight; }, true);

                mouseClick(header, header.width / 2, header.height / 2);
                verify(category.expandable);
                tryCompare(category, "filtered", true);
            }

            function test_filter_expand_expand_collapse() {
                // wait for the item to be there
                tryCompareFunction(function() { return findChild(genericScopeView, "dashSectionHeader2") != null; }, true);

                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.contentY = categoryListView.height;

                var header2 = findChild(genericScopeView, "dashSectionHeader2")
                var category2 = findChild(genericScopeView, "dashCategory2")
                var category2FilterGrid = category2.children[1].children[2];
                verify(UT.Util.isInstanceOf(category2FilterGrid, "CardFilterGrid"));

                waitForRendering(header2);
                verify(category2.expandable);
                verify(category2.filtered);

                mouseClick(header2, header2.width / 2, header2.height / 2);
                tryCompare(category2, "filtered", false);
                tryCompare(category2FilterGrid, "filtered", false);

                categoryListView.positionAtBeginning();

                var header0 = findChild(genericScopeView, "dashSectionHeader0")
                var category0 = findChild(genericScopeView, "dashCategory0")
                mouseClick(header0, header0.width / 2, header0.height / 2);
                tryCompare(category0, "filtered", false);
                tryCompare(category2, "filtered", true);
                tryCompare(category2FilterGrid, "filtered", true);
                mouseClick(header0, header0.width / 2, header0.height / 2);
                tryCompare(category0, "filtered", true);
                tryCompare(category2, "filtered", true);
            }

            function test_narrow_delegate_ranges_expand() {
                tryCompareFunction(function() { return findChild(genericScopeView, "dashCategory0") != undefined; }, true);
                var category = findChild(genericScopeView, "dashCategory0")
                tryCompare(category, "filtered", true);

                shell.width = units.gu(20)
                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.contentY = units.gu(20);
                var header0 = findChild(genericScopeView, "dashSectionHeader0")
                mouseClick(header0, header0.width / 2, header0.height / 2);
                tryCompare(category, "filtered", false);
                tryCompareFunction(function() { return category.item.height == genericScopeView.height - category.item.displayMarginBeginning - category.item.displayMarginEnd; }, true);
                mouseClick(header0, header0.width / 2, header0.height / 2);
                tryCompare(category, "filtered", true);
            }

            function openPreview() {
                tryCompareFunction(function() {
                                        var filterGrid = findChild(genericScopeView, "0");
                                        if (filterGrid != null) {
                                            var tile = findChild(filterGrid, "delegate0");
                                            return tile != null;
                                        }
                                        return false;
                                    },
                                    true);
                var tile = findChild(findChild(genericScopeView, "0"), "delegate0");
                mouseClick(tile, tile.width / 2, tile.height / 2);
                tryCompare(testCase.previewListView, "open", true);
                tryCompare(testCase.previewListView, "x", 0);
            }

            function closePreview() {
                var closePreviewMouseArea = findChild(genericScopeView, "innerPageHeader");
                mouseClick(closePreviewMouseArea, units.gu(2), units.gu(2));

                tryCompare(testCase.previewListView, "open", false);
            }

            function test_previewOpenClose() {
                tryCompare(testCase.previewListView, "open", false);

                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.positionAtBeginning();

                openPreview();
                closePreview();
            }

            function test_showPreviewCarousel() {
                tryCompareFunction(function() {
                                        var dashCategory1 = findChild(genericScopeView, "dashCategory1");
                                        if (dashCategory1 != null) {
                                            var tile = findChild(dashCategory1, "carouselDelegate1");
                                            return tile != null;
                                        }
                                        return false;
                                    },
                                    true);

                tryCompare(testCase.previewListView, "open", false);

                var dashCategory1 = findChild(genericScopeView, "dashCategory1");
                var tile = findChild(dashCategory1, "carouselDelegate1");
                mouseClick(tile, tile.width / 2, tile.height / 2);
                tryCompare(tile, "explicitlyScaled", true);
                mouseClick(tile, tile.width / 2, tile.height / 2);
                tryCompare(testCase.previewListView, "open", true);
                tryCompare(testCase.previewListView, "x", 0);

                closePreview();
            }

            function test_previewCycle() {
                var categoryListView = findChild(genericScopeView, "categoryListView");
                categoryListView.positionAtBeginning();

                tryCompare(testCase.previewListView, "open", false);
                var previewListViewList = findChild(previewListView, "listView");

                openPreview();

                // flick to the next previews
                tryCompare(testCase.previewListView, "count", 15);
                for (var i = 1; i < testCase.previewListView.count; ++i) {
                    mouseFlick(testCase.previewListView, testCase.previewListView.width - units.gu(1),
                                                testCase.previewListView.height / 2,
                                                units.gu(2),
                                                testCase.previewListView.height / 2);
                    tryCompare(previewListViewList, "moving", false);
                    tryCompare(testCase.previewListView.currentItem, "objectName", "previewItem" + i);

                }
                closePreview();
            }

            function test_header_style_data() {
                return [
                    { tag: "Default", index: 0, foreground: "grey", background: "", logo: "" },
                    { tag: "Foreground", index: 2, foreground: "yellow", background: "", logo: "" },
                    { tag: "Logo+Background", index: 3, foreground: "grey", background: "gradient:///lightgrey/grey",
                      logo: Qt.resolvedUrl("../Components/tst_PageHeader/logo-ubuntu-orange.svg") },
                ];
            }

            function test_header_style(data) {
                genericScopeView.scope = scopes.getScope(data.index);
                waitForRendering(genericScopeView);
                verify(header, "Could not find the header.");

                var innerHeader = findChild(header, "innerPageHeader");
                verify(innerHeader, "Could not find the inner header");
                verify(Qt.colorEqual(innerHeader.textColor, data.foreground),
                       "Foreground color not equal: %1 != %2".arg(innerHeader.textColor).arg(data.foreground));

                var background = findChild(header, "headerBackground");
                verify(background, "Could not find the background");
                compare(background.style, data.background);

                var image = findChild(genericScopeView, "titleImage");
                if (data.logo == "") expectFail(data.tag, "Title image should not exist.");
                verify(image, "Could not find the title image.");
                compare(image.source, data.logo, "Title image has the wrong source");
            }
        }
    }
}
