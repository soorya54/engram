import React, { useEffect, useState } from "react";
import { useParams } from "react-router";
import { Header } from "./header/Header";
import { removeNote, updateNote } from "./notes/NotesApi";
import TextBox from "./textbox/TextBox";
import { ListWidget, ListWidgetProps } from "./widgets/ListWidget/ListWidget";
import { getWidget, submitWidgetNote, WidgetData } from "./widgets/WidgetsApi";

export type ViewWidgetPageProps = {};

export type ViewWidgetPageParams = {
  widgetId: string;
};

export const ViewWidgetPage: React.FC<ViewWidgetPageProps> = (props) => {
  const { widgetId } = useParams<ViewWidgetPageParams>();
  const [widgetData, setWidgetData] = useState<WidgetData | null>(null);

  useEffect(() => {
    async function loadWidgetData() {
      const widget = await getWidget(widgetId);
      setWidgetData(widget);
    }

    loadWidgetData();
  }, [widgetId]);

  if (!widgetData) {
    return null;
  }

  const handleItemChanged: ListWidgetProps["onItemChanged"] = (item) => {
    updateNote(item);
  };

  const handleItemDeleted = (itemId?: string) => {
    removeNote(itemId);
    const widgetItemsCopy = Array.from(widgetData.items);
    const index = widgetItemsCopy.findIndex((item) => item._id === itemId);
    widgetItemsCopy.splice(index, 1);
    setWidgetData({
      ...widgetData,
      items: widgetItemsCopy,
    });
  };

  const handleSubmit = async (body: string) => {
    const newNote = await submitWidgetNote(widgetId, body);
    setWidgetData({
      ...widgetData,
      items: [...widgetData.items, newNote],
    });
  };

  return (
    <div className="view-widget-page">
      <Header title={widgetData.widget.name} />
      <ListWidget
        items={widgetData.items}
        onItemChanged={handleItemChanged}
        onItemDeleted={handleItemDeleted}
        checkboxes={widgetData.widget.checkboxes}
      />
      <TextBox onSubmit={handleSubmit} />
    </div>
  );
};