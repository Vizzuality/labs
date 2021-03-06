$(document).ready(function(){

  $("#installations_table").dataTable({
    "iDisplayLength": 25,
    "aoColumnDefs" : [{
      "bSortable": false,
      "aTargets": ["no-sort"]
    }]
  }).columnFilter({
    sPlaceHolder: "head:before",
    aoColumns: [
    {
      type: "text",
    },
    {
      type: "text",
    },
    {
      type: "text",
    },
    {
      type: "select",
      values: gon.roles
    },
    {
      type: "select",
      values: ["true", "false"]
    },
    null,
    null,
    null
    ]
  });
});
